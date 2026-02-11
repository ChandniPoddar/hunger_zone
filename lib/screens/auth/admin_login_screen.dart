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

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      // Default fallback
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
      body: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=2069&auto=format&fit=crop",
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD700), width: 2),
                      ),
                      child: const Icon(Icons.admin_panel_settings, size: 60, color: Color(0xFFFFD700)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "OUTLET ADMIN",
                      style: GoogleFonts.monoton(
                        color: const Color(0xFFFFD700),
                        fontSize: 28,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                      controller: _emailController,
                      hint: "Admin Email",
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
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFFFFD700),
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 40),
                    auth.loading
                        ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                        : SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () async {
                                final email = _emailController.text.trim().toLowerCase();
                                final password = _passwordController.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  Fluttertoast.showToast(msg: "Please fill all fields");
                                  return;
                                }

                                // Authenticate via Firebase
                                final msg = await auth.signIn(email: email, password: password);

                                if (msg != null) {
                                  Fluttertoast.showToast(msg: msg);
                                } else {
                                  if (!mounted) return;
                                  
                                  // Verify if it's one of our admin accounts
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
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Back to Consumer Login",
                        style: GoogleFonts.poppins(color: Colors.white70),
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
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
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
