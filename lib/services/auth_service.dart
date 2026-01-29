import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool _loading = false;
  bool get loading => _loading;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// 🔐 SIGN IN
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password cannot be empty';
    }

    try {
      _setLoading(true);
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // ✅ success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } finally {
      _setLoading(false);
    }
  }

  /// 🔐 SIGN UP
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password cannot be empty';
    }

    try {
      _setLoading(true);
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // ✅ success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Signup failed';
    } finally {
      _setLoading(false);
    }
  }

  /// 🚪 LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
