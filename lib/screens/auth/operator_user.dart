import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'admin_login_screen.dart';

class OperatorUserScreen extends StatefulWidget {
  const OperatorUserScreen({super.key});

  @override
  State<OperatorUserScreen> createState() => _OperatorUserScreenState();
}

class _OperatorUserScreenState extends State<OperatorUserScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _buttonController;
  late Animation<double> _scaleAnimation;

  // Consistent Brand Colors
  static const Color primaryCoral = Color(0xFFFF5252);
  static const Color primaryOrange = Color(0xFFFF7A59);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _buttonController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Icon Container
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryCoral, primaryOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryCoral.withValues(alpha: 0.28),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    "HUNGER ZONE",
                    style: GoogleFonts.poppins(
                      color: darkNavy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Welcome! Select your portal to continue",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 1. Consumer / Student Portal
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryCoral, primaryOrange],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: primaryCoral.withValues(alpha: 0.32),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Student / Consumer",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "Order food & live tracking",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withValues(alpha: 0.85),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Operator / Admin Portal
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: darkNavy.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.admin_panel_settings_outlined, color: darkNavy, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Canteen Staff / Admin",
                                        style: GoogleFonts.poppins(
                                          color: darkNavy,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "Manage incoming outlet orders",
                                        style: GoogleFonts.poppins(
                                          color: textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: textMuted, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Footer Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 16, color: textMuted),
                      const SizedBox(width: 6),
                      Text(
                        "Secure Email OTP & JWT Authentication",
                        style: GoogleFonts.poppins(
                          color: textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
