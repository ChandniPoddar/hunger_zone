import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String baseUrl = dotenv.env['BASE_URL'] ?? 'http://172.25.1.255:5000';
  static String razorpayKey = dotenv.env['RAZORPAY_KEY'] ?? 'rzp_test_SAodWBg2uq2dkh';
  static String defaultContact = dotenv.env['DEFAULT_CONTACT'] ?? '9876543210';
  static String defaultEmail = dotenv.env['DEFAULT_EMAIL'] ?? 'user@globaleats.com';
}
