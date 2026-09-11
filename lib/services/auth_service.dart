import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hunger_zone/utils/constants.dart';
import 'package:hunger_zone/services/notification_service.dart';

class AuthService extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? role;
  String? outletName;
  String? email;
  String? name;
  DateTime? lastVerified;

  // Compatibility getter so existing UI reading auth.phoneNumber won't crash before migration
  String? get phoneNumber => email;

  // Use AppConstants.baseUrl for the API
  static final String baseUrl = AppConstants.baseUrl;
  static const String _sessionKey = 'login_timestamp';
  static const int _oneWeekMillis = 7 * 24 * 60 * 60 * 1000;

  AuthService();

  /// ✅ USER OBJECT FOR PROFILE SCREEN
  Map<String, dynamic>? get currentUser {
    if (email == null) return null;
    return {
      "name": name,
      "email": email,
      "phoneNumber": email, // Fallback for components referencing phoneNumber
      "role": role,
      "outletName": outletName,
    };
  }

  /// ADMIN LOGIN SHORTCUTS (Using Email Addresses)
  final Map<String, Map<String, String>> _adminCredentials = {
    'admin.nescafe@hungerzone.com': {'pass': 'nescafe123', 'outlet': 'Nescafe'},
    'admin.lipton@hungerzone.com': {'pass': 'lipton123', 'outlet': 'Lipton'},
    'admin.canteen@hungerzone.com': {'pass': 'canteen123', 'outlet': 'Canteen'},
    'admin.fruit@hungerzone.com': {'pass': 'fruit123', 'outlet': 'Fruit Corner'},
  };

  Map<String, Map<String, String>> get adminCredentials => _adminCredentials;

  bool get isAdmin => role == 'admin' || role?.startsWith('admin_') == true;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// SESSION RESTORE & EXPIRY CHECK (1 WEEK PERSISTENT)
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTime = prefs.getInt(_sessionKey);

      if (loginTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch;

        // 1. Weekly check for everyone (1 week = 7 days)
        if (now - loginTime > _oneWeekMillis) {
          await logout();
          return false;
        }

        // Restore in-memory variables
        role = prefs.getString('role');
        email = prefs.getString('email') ?? prefs.getString('phoneNumber');
        name = prefs.getString('name');
        outletName = prefs.getString('outletName');

        // 2. Daily check for Operators
        if (role == 'operator') {
          final lastVerifStr = prefs.getString('last_verified_at');
          if (lastVerifStr != null) {
            final lastVerif = DateTime.parse(lastVerifStr);
            if (DateTime.now().difference(lastVerif).inHours >= 24) {
              await logout();
              return false; // Force re-verification
            }
          } else {
            await logout();
            return false;
          }
        }

        // If made it here, session is fully valid
        if (role != null && email != null) {
          // Sync FCM token with backend on session restore
          syncFcmToken();
          notifyListeners();
          return true;
        } else {
          await logout();
          return false;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> _saveLoginData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionKey, DateTime.now().millisecondsSinceEpoch);
      if (data['lastVerified'] != null) {
        await prefs.setString('last_verified_at', data['lastVerified'].toString());
      }

      if (role != null) await prefs.setString('role', role!);
      if (email != null) {
        await prefs.setString('email', email!);
        await prefs.setString('phoneNumber', email!); // backward compat
      }
      if (name != null) await prefs.setString('name', name!);
      if (outletName != null) await prefs.setString('outletName', outletName!);
    } catch (_) {}
  }

  /// ✅ SYNC FCM TOKEN WITH BACKEND
  Future<void> syncFcmToken() async {
    if (email == null) return;
    try {
      final token = await NotificationService.getFCMToken();
      if (token != null && token.isNotEmpty) {
        await registerFcmToken(token);
      }
    } catch (e) {
      debugPrint("Error syncing FCM token: $e");
    }
  }

  /// ✅ REGISTER FCM TOKEN ON BACKEND
  Future<void> registerFcmToken(String token) async {
    if (email == null) return;
    try {
      await http.post(
        Uri.parse("$baseUrl/notifications/register-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email!.trim().toLowerCase(),
          "fcmToken": token,
          "role": role,
          "outletName": outletName,
        }),
      );
    } catch (e) {
      debugPrint("Failed to register FCM token on backend: $e");
    }
  }

  /// ✅ REMOVE FCM TOKEN ON BACKEND (LOGOUT)
  Future<void> removeFcmToken(String token) async {
    if (email == null) return;
    try {
      await http.post(
        Uri.parse("$baseUrl/notifications/remove-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email!.trim().toLowerCase(),
          "fcmToken": token,
        }),
      );
    } catch (e) {
      debugPrint("Failed to remove FCM token on backend: $e");
    }
  }

  /// ✅ REQUEST EMAIL OTP
  Future<String?> requestOtp(String userEmail) async {
    try {
      setLoading(true);
      final response = await http.post(
        Uri.parse("$baseUrl/request-email-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": userEmail.trim().toLowerCase()}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return null;

      String msg = data["message"] ?? "Failed to send OTP";
      if (data["error"] != null) {
        msg = "$msg\nDetails: ${data["error"]}";
      }
      return msg;
    } catch (e) {
      return "Connection error. Please ensure backend is reachable.";
    } finally {
      setLoading(false);
    }
  }

  /// ✅ SIGN UP
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    required String otp,
  }) async {
    try {
      setLoading(true);

      final normalizedEmail = email.trim().toLowerCase();
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name.trim(),
          "email": normalizedEmail,
          "password": password,
          "role": role,
          "otp": otp.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        this.email = normalizedEmail;
        this.name = name.trim();
        this.role = data["role"] ?? role;

        await _saveLoginData(data);
        syncFcmToken();
        return null;
      } else {
        String msg = data["message"] ?? "Signup failed";
        if (data["error"] != null) {
          msg = "$msg: ${data["error"]}";
        }
        return msg;
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
      final normalizedEmail = email.trim().toLowerCase();

      /// 1. Check Admin Shortcuts first
      if (_adminCredentials.containsKey(normalizedEmail) &&
          _adminCredentials[normalizedEmail]!['pass'] == password) {
        role = "admin";
        outletName = _adminCredentials[normalizedEmail]!['outlet'];
        email = normalizedEmail;
        name = "${outletName!} Admin";
        await _saveLoginData({'lastVerified': DateTime.now().toIso8601String()});
        syncFcmToken();
        return null;
      }

      /// 2. MongoDB Login
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": normalizedEmail,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        role = data["role"] ?? "user";
        name = data["name"];
        outletName = data["outletName"];
        this.email = normalizedEmail;

        await _saveLoginData(data);
        syncFcmToken();
        return null;
      } else {
        return data["message"] ?? "Login failed";
      }
    } catch (e) {
      return "Server connection failed: $e";
    } finally {
      setLoading(false);
    }
  }

  /// ✅ DAILY VERIFY
  Future<String?> dailyVerify(String otp) async {
    if (email == null) return "User email not found";
    try {
      setLoading(true);
      final response = await http.post(
        Uri.parse("$baseUrl/daily-verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email!.trim().toLowerCase(),
          "otp": otp.trim(),
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
      final token = await NotificationService.getFCMToken();
      if (token != null && token.isNotEmpty) {
        await removeFcmToken(token);
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove('role');
      await prefs.remove('email');
      await prefs.remove('phoneNumber');
      await prefs.remove('name');
      await prefs.remove('outletName');
      await prefs.remove('last_verified_at');
    } catch (_) {}

    role = null;
    outletName = null;
    email = null;
    name = null;
    lastVerified = null;

    notifyListeners();
  }
}
