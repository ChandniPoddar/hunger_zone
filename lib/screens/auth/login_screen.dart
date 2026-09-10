import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../consumer/home_screen.dart';
import 'signup_screen.dart';
import 'operator_user.dart';
import 'admin_login_screen.dart';
import '../admin/nescafe_admin_dashboard.dart';
import '../admin/lipton_admin_dashboard.dart';
import '../admin/canteen_admin_dashboard.dart';
import '../admin/fruit_admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
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
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _navigateToCorrectAdminDashboard(String email, String? outlet) {
    Widget dashboard;
    final normalized = email.toLowerCase().trim();
    if (normalized == 'admin.nescafe@hungerzone.com' || outlet == 'Nescafe') {
      dashboard = const NescafeAdminDashboard();
    } else if (normalized == 'admin.lipton@hungerzone.com' || outlet == 'Lipton') {
      dashboard = const LiptonAdminDashboard();
    } else if (normalized == 'admin.canteen@hungerzone.com' || outlet == 'Canteen') {
      dashboard = const CanteenAdminDashboard();
    } else if (normalized == 'admin.fruit@hungerzone.com' || outlet == 'Fruit Corner') {
      dashboard = const FruitAdminDashboard();
    } else {
      dashboard = const HomeScreen();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dashboard));
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
                      child: Icon(Icons.lock_open_rounded, size: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Welcome Back",
                    style: GoogleFonts.poppins(
                      color: darkNavy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sign in with your registered email",
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
                          hint: "Enter your password",
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
                        const SizedBox(height: 28),

                        // Login Button
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
                                      final email = _emailController.text.trim();
                                      final password = _passwordController.text.trim();

                                      if (email.isEmpty || password.isEmpty) {
                                        Fluttertoast.showToast(msg: "Please fill all fields");
                                        return;
                                      }

                                      if (!email.contains("@") || !email.contains(".")) {
                                        Fluttertoast.showToast(msg: "Please enter a valid email address");
                                        return;
                                      }

                                      final errorMsg = await auth.signIn(email: email, password: password);
                                      if (errorMsg != null) {
                                        Fluttertoast.showToast(msg: errorMsg);
                                        return;
                                      }

                                      if (!context.mounted) return;
                                      if (auth.isAdmin) {
                                        _navigateToCorrectAdminDashboard(email, auth.outletName);
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
                                    child: Text(
                                      "SIGN IN",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
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

                  // Switch to Registration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.poppins(color: textMuted, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        ),
                        child: Text(
                          "Register Now",
                          style: GoogleFonts.poppins(
                            color: primaryCoral,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Admin Switcher
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                    ),
                    icon: const Icon(Icons.shield_outlined, size: 16, color: textMuted),
                    label: Text(
                      "Staff / Admin Portal",
                      style: GoogleFonts.poppins(
                        color: textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
