import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: "https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=2070&auto=format&fit=crop",
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.6),
              colorBlendMode: BlendMode.darken,
              placeholder: (context, url) => Container(color: Colors.black),
            ),
          ),

          // Decorative Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo/Icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
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
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 80,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      Text(
                        "GLOBAL EATS",
                        style: GoogleFonts.monoton(
                          color: const Color(0xFFFFD700),
                          fontSize: 32,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Choose your portal to excellence",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 60),

                      // User Login Button
                      _buildAnimatedButton(
                        title: "LOGIN FOR USER ONLY",
                        icon: Icons.person_outline_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 25),

                      // Operator Login Button
                      _buildAnimatedButton(
                        title: "LOGIN FOR OPERATOR ONLY",
                        icon: Icons.admin_panel_settings_outlined,
                        isOperator: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isOperator = false,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOperator
                  ? [const Color(0xFFFFD700), const Color(0xFFB8860B)]
                  : [Colors.white10, Colors.white.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOperator ? Colors.transparent : const Color(0xFFFFD700).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              if (isOperator)
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isOperator ? Colors.black : const Color(0xFFFFD700),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: isOperator ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
