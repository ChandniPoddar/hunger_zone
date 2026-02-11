import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool loading = false;
  String? role;
  String? outletName;

  User? get user => _auth.currentUser;

  AuthService() {
    _syncRoleLocally();
  }

  final Map<String, Map<String, String>> _adminCredentials = {
    'nescafe@gmail.com': {'pass': 'nescafe123', 'outlet': 'Nescafe'},
    'lipton@gmail.com': {'pass': 'lipton123', 'outlet': 'Lipton'},
    'canteen@gmail.com': {'pass': 'canteen123', 'outlet': 'Canteen'},
    'fruit@gmail.com': {'pass': 'fruit123', 'outlet': 'Fruit Corner'},
  };

  void _syncRoleLocally() {
    if (user != null) {
      final email = user!.email?.toLowerCase();
      if (_adminCredentials.containsKey(email)) {
        role = 'admin';
        outletName = _adminCredentials[email]!['outlet'];
        notifyListeners();
        return;
      }
    }
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    if (user == null) return;
    final email = user!.email?.toLowerCase();
    if (_adminCredentials.containsKey(email)) {
      role = 'admin';
      outletName = _adminCredentials[email]!['outlet'];
      notifyListeners();
      return;
    }
    try {
      final doc = await _db.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        role = doc.data()?['role'];
        outletName = doc.data()?['outletName'];
      } else {
        role = 'user';
      }
      notifyListeners();
    } catch (_) {}
  }

  bool get isAdmin => role == 'admin';

  Future<String?> signIn({required String email, required String password}) async {
    try {
      loading = true;
      notifyListeners();
      final lowEmail = email.toLowerCase().trim();

      // Set admin details instantly before even calling Firebase to prevent buffering
      if (_adminCredentials.containsKey(lowEmail) && _adminCredentials[lowEmail]!['pass'] == password) {
        role = 'admin';
        outletName = _adminCredentials[lowEmail]!['outlet'];
      }

      await _auth.signInWithEmailAndPassword(email: lowEmail, password: password);
      _syncRoleLocally();
      return null;
    } on FirebaseAuthException catch (e) {
      if ((e.code == 'user-not-found' || e.code == 'invalid-credential') &&
          _adminCredentials.containsKey(email.toLowerCase().trim())) {
        return await _autoRegisterAdmin(email.toLowerCase().trim(), password);
      }
      return e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> signUp({required String email, required String password}) async {
    try {
      loading = true;
      notifyListeners();
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      role = 'user';
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> _autoRegisterAdmin(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': 'admin',
        'outletName': _adminCredentials[email]!['outlet'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      role = 'admin';
      outletName = _adminCredentials[email]!['outlet'];
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    role = null;
    outletName = null;
    notifyListeners();
  }
}
