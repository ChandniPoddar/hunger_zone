import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String baseUrl = dotenv.env['BASE_URL'] ?? 'https://hunger-zone-api.onrender.com';
  static String razorpayKey = dotenv.env['RAZORPAY_KEY'] ?? 'rzp_test_SAodWBg2uq2dkh';
  static String defaultContact = dotenv.env['DEFAULT_CONTACT'] ?? '9876543210';
  static String defaultEmail = dotenv.env['DEFAULT_EMAIL'] ?? 'user@globaleats.com';
  static String receiverUpiAddress = dotenv.env['RECEIVER_UPI_ADDRESS'] ?? 'BHARATPE.9J0E0Z0U0M847077@unitype';
  static String receiverName = dotenv.env['RECEIVER_NAME'] ?? 'SIMON RAJKUMAR GROVER';
  static String merchantCode = dotenv.env['MERCHANT_CODE'] ?? '5812';
}
