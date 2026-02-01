import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool loading = false;

  User? get user => _auth.currentUser;

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
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
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

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
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
  }
}
