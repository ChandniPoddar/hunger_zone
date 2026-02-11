import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../consumer/home_screen.dart';
import 'signup_screen.dart';
import 'admin_login_screen.dart';
import '../admin/admin_dashboard.dart';
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
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _navigateToCorrectDashboard(String email) {
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
      dashboard = const AdminDashboard(outletName: "Admin");
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: "https://images.unsplash.com/photo-1559339352-11d035aa65de?q=80&w=1974&auto=format&fit=crop",
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.black),
              errorWidget: (context, url, error) => Container(color: Colors.black),
            ),
          ),
          
          // 2. Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.black.withValues(alpha: 0.6),
                    const Color(0xFF0F0F0F).withValues(alpha: 0.8),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // 3. Main Consumer Login Content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  children: [
                    // Top Space with Admin Shortcut
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                                  ),
                                  child: const Icon(Icons.admin_panel_settings, color: Color(0xFFFFD700), size: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Admin Login",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFFD700),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back 🍽️",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFFD700),
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                const Shadow(
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Login to your delicious food world",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// Animated Card
                    FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: ScaleTransition(
                          scale: _scale,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 20,
                                  offset: Offset(0, -5),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildTextField(
                                  controller: _emailController,
                                  hint: "Email",
                                  icon: Icons.email_outlined,
                                ),

                                const SizedBox(height: 20),

                                _buildTextField(
                                  controller: _passwordController,
                                  hint: "Password",
                                  icon: Icons.lock_outline,
                                  obscure: _obscurePassword,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFFFFD700),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(height: 40),

                                /// Login Button
                                auth.loading
                                    ? const CircularProgressIndicator(
                                        color: Color(0xFFFFD700),
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        height: 55,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFFFD700),
                                            foregroundColor: Colors.black,
                                            elevation: 10,
                                            shadowColor:
                                                const Color(0xFFFFD700),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () async {
                                            final email =
                                                _emailController.text.trim();
                                            final password =
                                                _passwordController.text.trim();

                                            if (email.isEmpty ||
                                                password.isEmpty) {
                                              Fluttertoast.showToast(
                                                  msg: "Please fill all fields");
                                              return;
                                            }

                                            final msg = await auth.signIn(
                                              email: email,
                                              password: password,
                                            );

                                            if (msg != null) {
                                              Fluttertoast.showToast(msg: msg);
                                              return;
                                            }

                                            if (!mounted) return;

                                            // Check role and navigate accordingly
                                            if (auth.isAdmin) {
                                              _navigateToCorrectDashboard(email);
                                            } else {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => const HomeScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            "LOGIN",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),

                                const SizedBox(height: 25),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don’t have an account?",
                                      style: GoogleFonts.poppins(color: Colors.white70),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SignupScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Sign Up",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFFFD700),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white38),
          prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
