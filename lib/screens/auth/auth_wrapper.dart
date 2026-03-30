import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ggi_canteen/utils/constants.dart';

class AuthService extends ChangeNotifier {

  bool loading = false;

  // Change to your backend URL
  final String baseUrl = "${AppConstants.baseUrl}/api";

  Map<String, dynamic>? currentUser;

  // ---------------- LOGIN ----------------
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      loading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        currentUser = data["user"];
        return null;
      } else {
        return data["message"];
      }
    } catch (e) {
      return e.toString();
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

      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        currentUser = data["user"];
        return null;
      } else {
        return data["message"];
      }
    } catch (e) {
      return e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ---------------- CURRENT USER ----------------
  Map<String, dynamic>? get user => currentUser;

  // ---------------- SIGN OUT ----------------
  Future<void> logout() async {
    currentUser = null;
    notifyListeners();
  }
}
