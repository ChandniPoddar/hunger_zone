import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const Color primaryCoral = Color(0xFFFF5252);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color neutralBg = Color(0xFFF8FAFC);
  static const Color mutedText = Color(0xFF64748B);

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _navigateToDashboard(String email, String? outlet) {
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
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dashboard));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: neutralBg,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 340,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    darkNavy.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        elevation: 1,
                        shadowColor: Colors.black12,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: darkNavy),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Admin Icon Badge
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: darkNavy,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryCoral.withValues(alpha: 0.35),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: darkNavy.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 48,
                            color: primaryCoral,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title & Subtitle
                    Text(
                      "Outlet Admin Portal",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: darkNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Authorized staff & outlet managers only",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: mutedText,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: darkNavy.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Admin Email",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: darkNavy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _emailController,
                            hint: "admin.nescafe@hungerzone.com",
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 20),

                          Text(
                            "Password",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: darkNavy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _passwordController,
                            hint: "Enter admin password",
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: mutedText,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Access Dashboard Button
                          Container(
                            height: 56,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: darkNavy,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: darkNavy.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: auth.loading
                                  ? null
                                  : () async {
                                      final email = _emailController.text.trim();
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
                                          'admin.nescafe@hungerzone.com',
                                          'admin.lipton@hungerzone.com',
                                          'admin.canteen@hungerzone.com',
                                          'admin.fruit@hungerzone.com',
                                        ];
                                        if (admins.contains(email.toLowerCase()) || auth.isAdmin) {
                                          _navigateToDashboard(email, auth.outletName);
                                        } else {
                                          Fluttertoast.showToast(msg: "Unauthorized admin access");
                                          await auth.logout();
                                        }
                                      }
                                    },
                              child: auth.loading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "ACCESS DASHBOARD",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            letterSpacing: 0.8,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.dashboard_customize_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Help notice
                    Center(
                      child: Text(
                        "Need assistance? Contact IT Support",
                        style: GoogleFonts.poppins(
                          color: mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        color: neutralBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
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
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: mutedText.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: darkNavy, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
