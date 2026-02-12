import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../services/auth_service.dart';
import '../admin/nescafe_admin_dashboard.dart';
import '../admin/lipton_admin_dashboard.dart';
import '../admin/canteen_admin_dashboard.dart';
import '../admin/fruit_admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _navigateToDashboard(String email) {
    Widget dashboard;
    if (email == 'nescafe@gmail.com') {
      dashboard = const NescafeAdminDashboard();
    } else if (email == 'lipton@gmail.com') {
      dashboard = const LiptonAdminDashboard();
    } else if (email == 'canteen@gmail.com') {
      dashboard = const CanteenAdminDashboard();
    } else if (email == 'fruit@gmail.com') {
      dashboard = const FruitAdminDashboard();
    } else {
      return;
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
      resizeToAvoidBottomInset: true, // Enabled keyboard-aware scrolling
      body: Stack(
        children: [
          // Full Screen Background Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=2069&auto=format&fit=crop",
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.7),
              colorBlendMode: BlendMode.darken,
              placeholder: (context, url) => Container(color: Colors.black),
            ),
          ),
          
          // Gradient for extra depth at the bottom
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Animated Header Icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFD700), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: const Icon(Icons.admin_panel_settings_rounded, size: 60, color: Color(0xFFFFD700)),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "OUTLET ADMIN",
                          style: GoogleFonts.monoton(
                            color: const Color(0xFFFFD700),
                            fontSize: 32,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Authorized Personnel Only",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 50),

                        // Input Fields
                        _buildTextField(
                          controller: _emailController,
                          hint: "Admin Email",
                          icon: Icons.alternate_email_rounded,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _passwordController,
                          hint: "Password",
                          icon: Icons.lock_person_rounded,
                          obscure: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: const Color(0xFFFFD700),
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Action Button
                        auth.loading
                            ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                            : SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD700),
                                    foregroundColor: Colors.black,
                                    elevation: 10,
                                    shadowColor: const Color(0xFFFFD700).withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  onPressed: () async {
                                    final email = _emailController.text.trim().toLowerCase();
                                    final password = _passwordController.text.trim();

                                    if (email.isEmpty || password.isEmpty) {
                                      Fluttertoast.showToast(msg: "Please fill all fields");
                                      return;
                                    }

                                    final msg = await auth.signIn(email: email, password: password);

                                    if (msg != null) {
                                      Fluttertoast.showToast(msg: msg);
                                    } else {
                                      if (!mounted) return;
                                      
                                      final admins = [
                                        'nescafe@gmail.com',
                                        'lipton@gmail.com',
                                        'canteen@gmail.com',
                                        'fruit@gmail.com'
                                      ];

                                      if (admins.contains(email)) {
                                        _navigateToDashboard(email);
                                      } else {
                                        Fluttertoast.showToast(msg: "Unauthorized admin access");
                                        await auth.logout();
                                      }
                                    }
                                  },
                                  child: Text(
                                    "ACCESS DASHBOARD",
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 30),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "BACK TO SELECTION",
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
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
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white38),
          prefixIcon: Icon(icon, color: const Color(0xFFFFD700), size: 22),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
