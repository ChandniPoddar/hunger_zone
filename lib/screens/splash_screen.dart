import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'auth/operator_user.dart';
import 'consumer/home_screen.dart';
import 'admin/nescafe_admin_dashboard.dart';
import 'admin/lipton_admin_dashboard.dart';
import 'admin/canteen_admin_dashboard.dart';
import 'admin/fruit_admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Consistent Brand Palette
  static const Color primaryGradientStart = Color(0xFFFF5252);
  static const Color primaryGradientEnd = Color(0xFFFF7A59);
  static const Color darkBg = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final auth = Provider.of<AuthService>(context, listen: false);

    // Smooth splash delay and session restore
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)),
      auth.restoreSession(),
    ]);

    if (!mounted) return;

    final bool hasValidSession = results[1] as bool;

    if (hasValidSession && (auth.email != null || auth.phoneNumber != null)) {
      if (auth.isAdmin || auth.role == 'operator') {
        final email = auth.email?.toLowerCase().trim();
        final outlet = auth.outletName;
        if (email == 'admin.nescafe@hungerzone.com' || outlet == 'Nescafe' || email == '9876543210') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NescafeAdminDashboard()));
        } else if (email == 'admin.lipton@hungerzone.com' || outlet == 'Lipton' || email == '9876543211') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LiptonAdminDashboard()));
        } else if (email == 'admin.canteen@hungerzone.com' || outlet == 'Canteen' || email == '9876543212') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CanteenAdminDashboard()));
        } else if (email == 'admin.fruit@hungerzone.com' || outlet == 'Fruit Corner' || email == '9876543213') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FruitAdminDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OperatorUserScreen()));
        }
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OperatorUserScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Ambient Radial Gradient Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryGradientStart.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryGradientEnd.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central Hero Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing Brand Emblem
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [primaryGradientStart, primaryGradientEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryGradientStart.withValues(alpha: 0.45),
                            blurRadius: 36,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // App Title
                    Text(
                      "HUNGER ZONE",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Modern Subtitle
                    Text(
                      "Campus Dining & Express Ordering",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Sleek Loader
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          primaryGradientStart.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Signature
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Fast • Fresh • Seamless",
                style: GoogleFonts.poppins(
                  color: Colors.white30,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
