import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../consumer/home_screen.dart';
import 'operator_user.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final bool isSignup;
  final Map<String, dynamic>? signupData;
  final bool isDailyVerify;

  const OTPScreen({
    super.key,
    required this.phone,
    this.isSignup = false,
    this.signupData,
    this.isDailyVerify = false,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  final Color primaryColor = const Color(0xFFFF6B6B);
  final Color darkTextColor = const Color(0xFF1A1A2E);

  Future<void> _submitOTP() async {
    final code = otpController.text.trim();
    final auth = context.read<AuthService>();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid 6 digit OTP")),
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
          phoneNumber: widget.phone,
          password: widget.signupData!['password'],
          role: widget.signupData!['role'],
          otp: code,
        );
      } else if (widget.isDailyVerify) {
        error = await auth.dailyVerify(code);
      } else {
        // Generic phone login (if implemented)
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
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: darkTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mark_email_read_rounded, size: 60, color: primaryColor),
              ),
              const SizedBox(height: 30),
              
              Text(
                "Verify OTP",
                style: GoogleFonts.poppins(
                  color: darkTextColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please enter the 6-digit code sent to\n${widget.phone}",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black45,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Form Card
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        letterSpacing: 10,
                        color: darkTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: "000000",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.black12,
                          letterSpacing: 10,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        counterText: "",
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 40),
                    isLoading
                        ? CircularProgressIndicator(color: primaryColor)
                        : SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _submitOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: Text(
                                "VERIFY & CONTINUE",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Incorrect number? Change it",
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
