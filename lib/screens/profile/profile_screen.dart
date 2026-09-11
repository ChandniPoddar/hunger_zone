import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../consumer/history_screen.dart';
import '../consumer/wishlist_screen.dart';
import '../consumer/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.colorScheme.onSurface;

    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: theme.appBarTheme.backgroundColor,
            iconTheme: theme.appBarTheme.iconTheme,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=2069&auto=format&fit=crop",
                    fit: BoxFit.cover,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            // 🌟 Optimized: Reduced top opacity to prevent "white fog" look
                            theme.scaffoldBackgroundColor.withValues(alpha: 0.15),
                            theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Hero(
                          tag: 'profile_avatar',
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: primaryColor, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: theme.colorScheme.surface,
                              child: Icon(Icons.person_rounded, size: 70, color: primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          user?["name"]?.toUpperCase() ?? "GUEST",
                          style: GoogleFonts.monoton(
                            color: primaryColor,
                            fontSize: 24,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          user?["email"] ?? user?["phoneNumber"] ?? "",
                          style: GoogleFonts.poppins(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Account Settings",
                        style: GoogleFonts.poppins(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileTile(
                        theme,
                        icon: Icons.person_outline_rounded,
                        title: "Personal Details",
                        onTap: () => _showPersonalDetailsModal(context, user),
                      ),
                      _buildProfileTile(
                        theme,
                        icon: Icons.shopping_bag_outlined,
                        title: "My Orders",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                      ),
                      _buildProfileTile(
                        theme,
                        icon: Icons.favorite_border_rounded,
                        title: "Favorites",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
                      ),
                      _buildProfileTile(
                        theme,
                        icon: Icons.notifications_none_rounded,
                        title: "Notifications",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                      ),
                      _buildProfileTile(
                        theme,
                        icon: Icons.payment_rounded,
                        title: "Payment Methods",
                        onTap: () => _showPaymentOptionsModal(context),
                      ),
                      _buildProfileTile(
                        theme,
                        icon: Icons.help_outline_rounded,
                        title: "Help & Support",
                        onTap: () => _showHelpSupportModal(context),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Colors.redAccent, width: 1.5),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: Text(
                            "SIGN OUT",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                          onPressed: () async {
                            await authService.logout();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 100),
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

  Widget _buildProfileTile(ThemeData theme, {required IconData icon, required String title, VoidCallback? onTap}) {
    final primaryColor = theme.primaryColor;
    final textColor = theme.colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: textColor.withValues(alpha: 0.3)),
        onTap: onTap,
      ),
    );
  }

  void _showPersonalDetailsModal(BuildContext context, Map<String, dynamic>? user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline_rounded, color: Color(0xFFFF6B6B), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  "Personal Details",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow("Full Name", user?['name'] ?? "Guest User", Icons.badge_outlined),
            const Divider(height: 24),
            _buildDetailRow("Email Address", user?['email'] ?? "Not provided", Icons.email_outlined),
            const Divider(height: 24),
            _buildDetailRow("Account Role", (user?['role'] ?? "user").toString().toUpperCase(), Icons.security_outlined),
            const Divider(height: 24),
            _buildDetailRow("Status", "Email Verified", Icons.verified_user_outlined, color: const Color(0xFF28A745)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text("Done", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPaymentOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text("Accepted Payment Methods", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFFFF6B6B)),
              title: Text("UPI Direct Intent", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text("Google Pay, PhonePe, Paytm, BHIM", style: GoogleFonts.poppins(fontSize: 12)),
            ),
            ListTile(
              leading: const Icon(Icons.payments_outlined, color: Color(0xFF28A745)),
              title: Text("Cash at Counter (COD)", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text("Pay in cash when picking up your food", style: GoogleFonts.poppins(fontSize: 12)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showHelpSupportModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.help_outline_rounded, color: Color(0xFFFF6B6B)),
            ),
            const SizedBox(width: 12),
            Text("Help & Support", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Campus Canteen Information", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              "• Service Hours: 8:30 AM - 7:00 PM\n• Outlets: Main Canteen, Nescafe, Lipton, Fruit Corner\n• Counter: Campus Food Court Ground Floor\n• Email Support: support@hungerzone.com",
              style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade700, height: 1.6),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Close", style: GoogleFonts.poppins(color: const Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
