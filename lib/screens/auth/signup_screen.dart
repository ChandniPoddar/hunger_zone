import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Consistent Brand Colors
  static const Color primaryCoral = Color(0xFFFF5252);
  static const Color primaryOrange = Color(0xFFFF7A59);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Brand Icon Emblem
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryCoral, primaryOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryCoral.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.person_add_alt_1_rounded, size: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                      color: darkNavy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sign up with your email to start ordering",
                    style: GoogleFonts.poppins(
                      color: textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Container Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderSubtle, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name Label
                        Text(
                          "Full Name",
                          style: GoogleFonts.poppins(
                            color: darkNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _nameController,
                          hint: "John Doe",
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 18),

                        // Email Label
                        Text(
                          "Email Address",
                          style: GoogleFonts.poppins(
                            color: darkNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _emailController,
                          hint: "student@ggi.ac.in",
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),

                        // Password Label
                        Text(
                          "Password",
                          style: GoogleFonts.poppins(
                            color: darkNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _passwordController,
                          hint: "Create a password (min 6 chars)",
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: textMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notice
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryCoral.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryCoral.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.mark_email_read_outlined, color: primaryCoral, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "A 6-digit OTP will be sent to your email to verify your identity.",
                                  style: GoogleFonts.poppins(
                                    color: darkNavy,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Submit Button
                        auth.loading
                            ? const Center(
                                child: CircularProgressIndicator(color: primaryCoral),
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [primaryCoral, primaryOrange],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
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
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    onPressed: () async {
                                      final name = _nameController.text.trim();
                                      final email = _emailController.text.trim();
                                      final password = _passwordController.text.trim();

                                      if (name.isEmpty || email.isEmpty || password.isEmpty) {
                                        Fluttertoast.showToast(msg: "Please fill all fields");
                                        return;
                                      }

                                      if (!email.contains("@") || !email.contains(".")) {
                                        Fluttertoast.showToast(msg: "Please enter a valid email address");
                                        return;
                                      }

                                      if (password.length < 6) {
                                        Fluttertoast.showToast(msg: "Password must be at least 6 characters");
                                        return;
                                      }

                                      final String? error = await auth.requestOtp(email);

                                      if (!context.mounted) return;
                                      if (error == null) {
                                        Fluttertoast.showToast(msg: "Verification code sent to $email");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => OTPScreen(
                                              email: email,
                                              isSignup: true,
                                              signupData: {
                                                'name': name,
                                                'password': password,
                                                'role': 'user',
                                              },
                                            ),
                                          ),
                                        );
                                      } else {
                                        Fluttertoast.showToast(msg: error);
                                      }
                                    },
                                    child: Text(
                                      "SEND VERIFICATION OTP",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        letterSpacing: 1.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: GoogleFonts.poppins(color: textMuted, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Sign In",
                          style: GoogleFonts.poppins(
                            color: primaryCoral,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderSubtle),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          color: darkNavy,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: textMuted.withValues(alpha: 0.6), fontSize: 14),
          prefixIcon: Icon(icon, color: primaryCoral, size: 20),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
