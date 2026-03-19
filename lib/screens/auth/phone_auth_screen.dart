import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scale = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    phoneController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {

    FocusScope.of(context).unfocus();

    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: "Phone number required");
      return;
    }

    if (phone.length != 10) {
      Fluttertoast.showToast(msg: "Enter valid 10 digit number");
      return;
    }

    final fullPhone = "+91$phone";

    setState(() {
      isLoading = true;
    });

    try {

      /// TODO: Call your backend API here
      /// Example:
      /// await ApiService.sendOtp(fullPhone);

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPScreen(
            phone: fullPhone,
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
        msg: "Failed to send OTP",
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0F0F),
              Color(0xFF2A2A2A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 90),

            /// HEADER
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Verify Phone 📱",
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Enter your mobile number",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// MAIN CARD
            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),

                      child: SingleChildScrollView(
                        child: Column(
                          children: [

                            const SizedBox(height: 50),

                            /// PHONE FIELD
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.grey.shade800,
                                ),
                              ),

                              child: Row(
                                children: [

                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      "+91",
                                      style: TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: TextField(
                                      controller: phoneController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        letterSpacing: 2,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "XXXXXXXXXX",
                                        hintStyle: TextStyle(
                                          color: Colors.white38,
                                          letterSpacing: 2,
                                        ),
                                        counterText: "",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            /// SEND OTP BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD700),
                                  foregroundColor: Colors.black,
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: isLoading ? null : _sendOtp,
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                                    : const Text(
                                  "SEND OTP",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            const Text(
                              "A 6-digit OTP will be sent to your phone.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 20),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
