import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Verify OTP", style: TextStyle(color: Color(0xFFFFD700))),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 80, color: Color(0xFFFFD700)),
              const SizedBox(height: 30),
              Text(
                "Verification Code",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Please enter the 6-digit code sent to\n${widget.phone}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white60),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 8, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "000000",
                  hintStyle: TextStyle(color: Colors.white10),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                  counterText: "",
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("VERIFY & CONTINUE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Incorrect number? Change it", style: TextStyle(color: Color(0xFFFFD700))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
