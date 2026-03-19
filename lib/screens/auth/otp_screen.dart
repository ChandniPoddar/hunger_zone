import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../consumer/home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phone;

  const OTPScreen({
    super.key,
    required this.phone,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();

  bool isLoading = false;

  Future<void> _submitOTP() async {
    final code = otpController.text.trim();

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
      /// DEBUG MODE (skip backend)
      if (kDebugMode) {
        await Future.delayed(const Duration(seconds: 1));
      } else {
        /// TODO: Call your backend verify OTP API
        /// Example:
        /// await ApiService.verifyOtp(widget.phone, code);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP")),
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
      appBar: AppBar(
        title: const Text("Enter OTP"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              "OTP sent to ${widget.phone}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                letterSpacing: 6,
              ),
              decoration: const InputDecoration(
                hintText: "------",
                border: OutlineInputBorder(),
                counterText: "",
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,

              child: ElevatedButton(
                onPressed: isLoading ? null : _submitOTP,

                child: isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text("Verify OTP"),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Change phone number"),
            ),

          ],
        ),
      ),
    );
  }
}
