import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/auth_service.dart';
import '../consumer/home_screen.dart';
import 'operator_user.dart';

class OTPScreen extends StatefulWidget {
  final String? email;
  final String? phone; // backward compatibility
  final bool isSignup;
  final Map<String, dynamic>? signupData;
  final bool isDailyVerify;

  const OTPScreen({
    super.key,
    this.email,
    this.phone,
    this.isSignup = false,
    this.signupData,
    this.isDailyVerify = false,
  });

  String get targetEmail => email ?? phone ?? "";

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  int _resendCountdown = 60;
  Timer? _timer;
  bool _canResend = false;

  static const Color primaryCoral = Color(0xFFFF5252);
  static const Color primaryOrange = Color(0xFFFF7A59);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color neutralBg = Color(0xFFF8FAFC);
  static const Color mutedText = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;
    final auth = context.read<AuthService>();
    final error = await auth.requestOtp(widget.targetEmail);
    if (!mounted) return;
    if (error == null) {
      Fluttertoast.showToast(msg: "A new OTP was sent to ${widget.targetEmail}");
      _startCountdown();
    } else {
      Fluttertoast.showToast(msg: error);
    }
  }

  Future<void> _submitOTP() async {
    final code = otpController.text.trim();
    final auth = context.read<AuthService>();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter a valid 6-digit code",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: darkNavy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? error;
      if (widget.isSignup) {
        error = await auth.signUp(
          name: widget.signupData!['name'],
          email: widget.targetEmail,
          password: widget.signupData!['password'],
          role: widget.signupData!['role'],
          otp: code,
        );
      } else if (widget.isDailyVerify) {
        error = await auth.dailyVerify(code);
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!mounted) return;

      if (error != null) {
        throw error;
      }

      // Success Navigation
      if (auth.role == 'operator') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OperatorUserScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: primaryCoral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralBg,
      body: Stack(
        children: [
          // Background Glow Decoration
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    primaryCoral.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Back Bar
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      elevation: 1,
                      shadowColor: Colors.black12,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(14),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: darkNavy),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header Badge Icon
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryCoral.withValues(alpha: 0.15),
                            primaryOrange.withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryCoral.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mark_email_read_rounded,
                          size: 46,
                          color: primaryCoral,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title & Description
                  Text(
                    "Verify Your Email",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: darkNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We've sent a 6-digit verification code to",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: mutedText,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Email Pill Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: darkNavy.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: darkNavy.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mail_rounded, size: 16, color: primaryCoral),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.targetEmail,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: darkNavy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Verification Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: darkNavy.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Enter 6-Digit Code",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: mutedText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Styled OTP Field
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: neutralBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryCoral.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              letterSpacing: 14,
                              color: darkNavy,
                              fontWeight: FontWeight.w800,
                            ),
                            decoration: InputDecoration(
                              hintText: "••••••",
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.black26,
                                letterSpacing: 14,
                                fontSize: 26,
                              ),
                              border: InputBorder.none,
                              counterText: "",
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Resend Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: _canResend ? primaryCoral : mutedText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _canResend
                                  ? "Didn't receive the code? "
                                  : "Resend available in ${_resendCountdown}s",
                              style: GoogleFonts.poppins(
                                color: mutedText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_canResend)
                              GestureDetector(
                                onTap: _resendOTP,
                                child: Text(
                                  "Resend",
                                  style: GoogleFonts.poppins(
                                    color: primaryCoral,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        // Verify & Continue Button
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [primaryCoral, primaryOrange],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryCoral.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "VERIFY & CONTINUE",
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Go back / Change email link
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16, color: mutedText),
                      label: Text(
                        "Wrong email? Go back & change",
                        style: GoogleFonts.poppins(
                          color: mutedText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
