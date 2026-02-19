import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool loading = false;
  String? role;
  String? outletName;

  User? get user => _auth.currentUser;

  AuthService() {
    _quickInitRole();
    _checkSessionExpiry();
  }

  final Map<String, Map<String, String>> _adminCredentials = {
    'nescafe@gmail.com': {'pass': 'nescafe123', 'outlet': 'Nescafe'},
    'lipton@gmail.com': {'pass': 'lipton123', 'outlet': 'Lipton'},
    'canteen@gmail.com': {'pass': 'canteen123', 'outlet': 'Canteen'},
    'fruit@gmail.com': {'pass': 'fruit123', 'outlet': 'Fruit Corner'},
  };

  static const String _sessionKey = 'login_timestamp';
  static const int _oneWeekMillis = 7 * 24 * 60 * 60 * 1000;

  Future<void> _checkSessionExpiry() async {
    try {
      final email = user?.email?.toLowerCase();
      if (email != null && !_adminCredentials.containsKey(email)) {
        final prefs = await SharedPreferences.getInstance();
        final loginTime = prefs.getInt(_sessionKey);
        if (loginTime != null) {
          if (DateTime.now().millisecondsSinceEpoch - loginTime > _oneWeekMillis) {
            await logout();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _saveLoginTime() async {
    try {
      final email = user?.email?.toLowerCase();
      if (email != null && !_adminCredentials.containsKey(email)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_sessionKey, DateTime.now().millisecondsSinceEpoch);
      }
    } catch (_) {}
  }

  void _quickInitRole() {
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
    if (user == null) {
      role = null;
      outletName = null;
      notifyListeners();
      return;
    }

    final email = user!.email?.toLowerCase();
    if (_adminCredentials.containsKey(email)) {
      role = 'admin';
      outletName = _adminCredentials[email]!['outlet'];
      notifyListeners();
      return;
    }

    try {
      final doc = await _db.collection('users').doc(user!.uid).get().timeout(const Duration(seconds: 3));
      if (doc.exists) {
        role = doc.data()?['role'];
        outletName = doc.data()?['outletName'];
      } else {
        role = 'user';
      }
    } catch (_) {
      role = 'user';
    }
    notifyListeners();
  }

  bool get isAdmin => role == 'admin';

  Future<String?> signIn({required String email, required String password}) async {
    try {
      loading = true;
      notifyListeners();
      final lowEmail = email.toLowerCase().trim();

      // 🌟 OPTIMIZED: Set admin roles BEFORE network calls
      if (_adminCredentials.containsKey(lowEmail) && _adminCredentials[lowEmail]!['pass'] == password) {
        role = 'admin';
        outletName = _adminCredentials[lowEmail]!['outlet'];
      }

      try {
        await _auth.signInWithEmailAndPassword(email: lowEmail, password: password);
        await _saveLoginTime(); 
      } on FirebaseAuthException catch (e) {
        if ((e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'invalid-email') &&
            _adminCredentials.containsKey(lowEmail)) {
          final res = await _autoRegisterAdmin(lowEmail, password);
          // No need to save session time for admins
          return res;
        }
        return e.message;
      }
      
      // 🌟 OPTIMIZED: Skip heavy DB sync for known admins
      if (!_adminCredentials.containsKey(lowEmail)) {
        await _checkUserRole();
      }
      return null;
    } catch (e) {
      return "An unexpected error occurred.";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> signUp({required String email, required String password}) async {
    try {
      loading = true;
      notifyListeners();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      role = 'user';
      await _saveLoginTime(); 
      
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch(e) {
      return "An unexpected error occurred.";
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
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {}
    role = null;
    outletName = null;
    notifyListeners();
  }
}
