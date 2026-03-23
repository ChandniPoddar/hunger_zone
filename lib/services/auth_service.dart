import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? role;
  String? outletName;
  String? email;
  String? name;

  // Use 172.20.2.13 for Android Physical Device
  static const String baseUrl = "http://172.20.2.13:5000";
  static const String _sessionKey = 'login_timestamp';
  static const int _oneWeekMillis = 7 * 24 * 60 * 60 * 1000;

  AuthService() {
    _checkSessionExpiry();
  }

  /// ✅ USER OBJECT FOR PROFILE SCREEN
  Map<String, dynamic>? get currentUser {
    if (email == null) return null;
    return {
      "name": name,
      "email": email,
      "role": role,
      "outletName": outletName,
    };
  }

  /// ADMIN LOGIN SHORTCUTS
  final Map<String, Map<String, String>> _adminCredentials = {
    'nescafe@gmail.com': {'pass': 'nescafe123', 'outlet': 'Nescafe'},
    'lipton@gmail.com': {'pass': 'lipton123', 'outlet': 'Lipton'},
    'canteen@gmail.com': {'pass': 'canteen123', 'outlet': 'Canteen'},
    'fruit@gmail.com': {'pass': 'fruit123', 'outlet': 'Fruit Corner'},
  };

  bool get isAdmin => role == 'admin' || role?.startsWith('admin_') == true;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// SESSION EXPIRY CHECK
  Future<void> _checkSessionExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTime = prefs.getInt(_sessionKey);

      if (loginTime != null) {
        if (DateTime.now().millisecondsSinceEpoch - loginTime > _oneWeekMillis) {
          await logout();
        }
      }
    } catch (_) {}
  }

  Future<void> _saveLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// ✅ UPDATED SIGN UP (Supports MongoDB Schema)
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      setLoading(true);

      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email.toLowerCase().trim(),
          "password": password,
          "role": role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        this.email = email.toLowerCase().trim();
        this.name = name;
        this.role = data["role"] ?? role;

        await _saveLoginTime();
        return null; // Success
      } else {
        return data["message"] ?? "Signup failed";
      }
    } catch (e) {
      return "Server connection failed: $e";
    } finally {
      setLoading(false);
    }
  }

  /// ✅ SIGN IN
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      setLoading(true);
      final lowEmail = email.toLowerCase().trim();

      /// 1. Check Admin Shortcuts first
      if (_adminCredentials.containsKey(lowEmail) &&
          _adminCredentials[lowEmail]!['pass'] == password) {
        this.role = "admin";
        this.outletName = _adminCredentials[lowEmail]!['outlet'];
        this.email = lowEmail;
        await _saveLoginTime();
        return null;
      }

      /// 2. MongoDB Login
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": lowEmail,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        this.role = data["role"] ?? "user";
        this.name = data["name"];
        this.outletName = data["outletName"];
        this.email = lowEmail;

        await _saveLoginTime();
        return null;
      } else {
        return data["message"] ?? "Login failed";
      }
    } catch (e) {
      return "Server connection failed";
    } finally {
      setLoading(false);
    }
  }

  /// ✅ LOGOUT
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {}

    role = null;
    outletName = null;
    email = null;
    name = null;

    notifyListeners();
  }
}