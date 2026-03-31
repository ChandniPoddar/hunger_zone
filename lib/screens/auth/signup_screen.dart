import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import 'otp_screen.dart';
// Note: HomeScreen and OperatorUserScreen imports can stay if you use them elsewhere,
// but for the "Navigate to Login" requirement, we will use Navigator.pop or pushReplacement.

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use context.read inside the button for actions,
    // and context.watch here to listen for the 'loading' state.
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070&auto=format&fit=crop",
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6),
              colorBlendMode: BlendMode.darken,
              placeholder: (context, url) => Container(color: Colors.black),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5), Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFD700), width: 2),
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded, size: 60, color: Color(0xFFFFD700)),
                        ),
                        const SizedBox(height: 24),
                        Text("Create Account ✨",
                            style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 40),
                        _buildTextField(
                          controller: _nameController,
                          hint: "Full Name",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _phoneController,
                          hint: "Phone Number",
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _passwordController,
                          hint: "Password",
                          icon: Icons.lock_rounded,
                          obscure: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFFFD700)),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 40),
                        auth.loading
                            ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                            : SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () async {
                              final name = _nameController.text.trim();
                              final phone = _phoneController.text.trim();
                              final password = _passwordController.text.trim();

                              if (name.isEmpty || phone.isEmpty || password.isEmpty) {
                                Fluttertoast.showToast(msg: "Please fill all fields");
                                return;
                              }

                              // Request OTP first
                              final String? error = await auth.requestOtp(phone);

                              if (error == null && mounted) {
                                Fluttertoast.showToast(msg: "OTP sent to $phone");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OTPScreen(
                                      phone: phone,
                                      isSignup: true,
                                      signupData: {
                                        'name': name,
                                        'password': password,
                                        'role': 'user',
                                      },
                                    ),
                                  ),
                                );
                              } else if (error != null) {
                                Fluttertoast.showToast(msg: error);
                              }
                            },
                            child: Text("SIGN UP", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?", style: TextStyle(color: Colors.white70)),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Login", style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
