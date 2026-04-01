import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hunger_zone/utils/constants.dart';

class AuthService extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? role;
  String? outletName;
  String? phoneNumber;
  String? name;
  DateTime? lastVerified;

  // Use AppConstants.baseUrl for the API
  static final String baseUrl = AppConstants.baseUrl;
  static const String _sessionKey = 'login_timestamp';
  static const int _oneWeekMillis = 7 * 24 * 60 * 60 * 1000;

  AuthService() {
    _checkSessionExpiry();
  }

  /// ✅ USER OBJECT FOR PROFILE SCREEN
  Map<String, dynamic>? get currentUser {
    if (phoneNumber == null) return null;
    return {
      "name": name,
      "phoneNumber": phoneNumber,
      "role": role,
      "outletName": outletName,
    };
  }

  /// ADMIN LOGIN SHORTCUTS (Updated to Phone Numbers)
  final Map<String, Map<String, String>> _adminCredentials = {
    '9876543210': {'pass': 'nescafe123', 'outlet': 'Nescafe'},
    '9876543211': {'pass': 'lipton123', 'outlet': 'Lipton'},
    '9876543212': {'pass': 'canteen123', 'outlet': 'Canteen'},
    '9876543213': {'pass': 'fruit123', 'outlet': 'Fruit Corner'},
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
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // 1. Weekly check for everyone
        if (now - loginTime > _oneWeekMillis) {
          await logout();
          return;
        }

        // 2. Daily check for Operators
        if (role == 'operator') {
          final lastVerifStr = prefs.getString('last_verified_at');
          if (lastVerifStr != null) {
            final lastVerif = DateTime.parse(lastVerifStr);
            if (DateTime.now().difference(lastVerif).inHours >= 24) {
              // Need re-verification
              // Note: Usually we'd redirect to a verification screen. 
              // For now, we'll force logout or set a flag.
              await logout();
            }
          } else {
            await logout();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _saveLoginData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionKey, DateTime.now().millisecondsSinceEpoch);
      if (data['lastVerified'] != null) {
        await prefs.setString('last_verified_at', data['lastVerified']);
      }
    } catch (_) {}
  }

  /// ✅ REQUEST OTP
  Future<String?> requestOtp(String phone) async {
    try {
      setLoading(true);
      final response = await http.post(
        Uri.parse("$baseUrl/request-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phoneNumber": phone}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return null;
      
      String msg = data["message"] ?? "Failed to send OTP";
      if (data["error"] != null) {
        msg = "$msg\nDetails: ${data["error"]}";
      }
      return msg;
    } catch (e) {
      return "Connection error";
    } finally {
      setLoading(false);
    }
  }

  /// ✅ SIGN UP
  Future<String?> signUp({
    required String name,
    required String phoneNumber,
    required String password,
    required String role,
    required String otp,
  }) async {
    try {
      setLoading(true);

      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phoneNumber": phoneNumber,
          "password": password,
          "role": role,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        this.phoneNumber = phoneNumber;
        this.name = name;
        this.role = data["role"] ?? role;

        await _saveLoginData(data);
        return null;
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
    required String phoneNumber,
    required String password,
  }) async {
    try {
      setLoading(true);

      /// 1. Check Admin Shortcuts first
      if (_adminCredentials.containsKey(phoneNumber) &&
          _adminCredentials[phoneNumber]!['pass'] == password) {
        this.role = "admin";
        this.outletName = _adminCredentials[phoneNumber]!['outlet'];
        this.phoneNumber = phoneNumber;
        await _saveLoginData({'lastVerified': DateTime.now().toIso8601String()});
        return null;
      }

      /// 2. MongoDB Login
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phoneNumber": phoneNumber,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        this.role = data["role"] ?? "user";
        this.name = data["name"];
        this.outletName = data["outletName"];
        this.phoneNumber = phoneNumber;

        await _saveLoginData(data);
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

  /// ✅ DAILY VERIFY
  Future<String?> dailyVerify(String otp) async {
    try {
      setLoading(true);
      final response = await http.post(
        Uri.parse("$baseUrl/daily-verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phoneNumber": phoneNumber,
          "otp": otp,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await _saveLoginData(data);
        return null;
      }
      return data["message"] ?? "Verification failed";
    } catch (e) {
      return "Connection error";
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
    phoneNumber = null;
    name = null;
    lastVerified = null;

    notifyListeners();
  }
}
