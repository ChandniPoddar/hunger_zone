import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../consumer/home_screen.dart';
import 'signup_screen.dart';
import 'operator_user.dart'; // Ensure this matches your filename
import '../admin/nescafe_admin_dashboard.dart';
import '../admin/lipton_admin_dashboard.dart';
import '../admin/canteen_admin_dashboard.dart';
import '../admin/fruit_admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
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
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Handles routing for Admin Emails
  void _navigateToCorrectAdminDashboard(String email) {
    Widget dashboard;
    final lowEmail = email.toLowerCase();

    if (lowEmail == 'nescafe@gmail.com') {
      dashboard = const NescafeAdminDashboard();
    } else if (lowEmail == 'lipton@gmail.com') {
      dashboard = const LiptonAdminDashboard();
    } else if (lowEmail == 'canteen@gmail.com') {
      dashboard = const CanteenAdminDashboard();
    } else if (lowEmail == 'fruit@gmail.com') {
      dashboard = const FruitAdminDashboard();
    } else {
      dashboard = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: "https://images.unsplash.com/photo-1559339352-11d035aa65de?q=80&w=1974&auto=format&fit=crop",
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
                        const Icon(Icons.restaurant_menu_rounded, size: 80, color: Color(0xFFFFD700)),
                        const SizedBox(height: 24),

                        Text("Welcome Back 🍽️",
                            style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 40),

                        _buildTextField(
                          controller: _emailController,
                          hint: "Email",
                          icon: Icons.email_rounded,
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
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();

                              if (email.isEmpty || password.isEmpty) {
                                Fluttertoast.showToast(msg: "Please fill all fields");
                                return;
                              }

                              final errorMsg = await auth.signIn(email: email, password: password);

                              if (errorMsg != null) {
                                Fluttertoast.showToast(msg: errorMsg);
                                return;
                              }

                              if (!mounted) return;

                              // ✅ ROLE-BASED NAVIGATION
                              if (auth.isAdmin) {
                                _navigateToCorrectAdminDashboard(email);
                              } else if (auth.role == 'operator') {
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
                            },
                            child: Text("LOGIN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1.2)),
                          ),
                        ),

                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don’t have an account?", style: TextStyle(color: Colors.white70)),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                              child: const Text("Sign Up", style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
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