import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'auth/operator_user.dart';
import 'consumer/home_screen.dart';

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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    _navigateNext();
  }

  Future<void> _navigateNext() async {

    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    final auth = Provider.of<AuthService>(context, listen: false);

    /// If user logged in
    if (auth.phoneNumber != null) {

      final phone = auth.phoneNumber!;

      /// Hardcoded Admin Phone Numbers
      final adminPhones = [
        '9876543210',
        '9876543211',
        '9876543212',
        '9876543213'
      ];

      /// Admins must always login again
      if (adminPhones.contains(phone)) {
        await auth.logout();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OperatorUserScreen()),
        );
      } else {
        /// Normal user → go to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {

      /// Not logged in
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const OperatorUserScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
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
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          /// Background Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl:
              "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?q=80&w=2070&auto=format&fit=crop",
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: Colors.black),
              errorWidget: (context, url, error) =>
                  Container(color: Colors.black),
            ),
          ),

          /// Dark Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.6),
                    const Color(0xFF0F0F0F).withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          /// Logo + Title
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,

              child: ScaleTransition(
                scale: _scaleAnimation,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    /// Logo
                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ],
                      ),

                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 80,
                        color: Color(0xFFFFD700),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// App Name
                    Text(
                      "GLOBAL EATS",

                      style: GoogleFonts.monoton(
                        color: const Color(0xFFFFD700),
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Tagline
                    Text(
                      "Taste the World, One Plate at a Time",

                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 100),

                    /// Loading
                    const CircularProgressIndicator(
                      color: Color(0xFFFFD700),
                      strokeWidth: 2,
                    ),

                    const SizedBox(height: 40),

                    /// Credit
                    Text(
                      "Designed by Chandni",

                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 14,
                        letterSpacing: 1.2,
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
}
