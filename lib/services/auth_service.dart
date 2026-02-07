import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool loading = false;
  String? role;

  User? get user => _auth.currentUser;

  AuthService() {
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      if (user != null) {
        final doc = await _db.collection('users').doc(user!.uid).get();
        if (doc.exists) {
          role = doc.data()?['role'];
        } else {
          role = 'user'; // Default if doc doesn't exist
        }
      } else {
        role = null;
      }
    } catch (e) {
      // 🌟 Optimistic Fix: Default to 'user' if Firestore is unavailable/not setup
      debugPrint("Firestore role check skipped (Database not setup?): $e");
      if (user != null) {
        role = 'user';
      } else {
        role = null;
      }
    }
    notifyListeners();
  }

  bool get isAdmin => role == 'admin';

  // ---------------- LOGIN ----------------
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      loading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Attempt role check but don't let it block navigation
      _checkUserRole(); 
      
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ---------------- SIGNUP ----------------
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      loading = true;
      notifyListeners();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user doc in Firestore (optional/failsafe)
      try {
        await _db.collection('users').doc(result.user!.uid).set({
          'email': email,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint("Silent Firestore setup error: $e");
      }

      await _checkUserRole();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ---------------- PHONE CHECK ----------------
  bool get isPhoneVerified {
    final u = _auth.currentUser;
    if (u == null) return false;
    return u.providerData.any((p) => p.providerId == 'phone');
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    await _auth.signOut();
    role = null;
    notifyListeners();
  }
}
