import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class LiptonAdminDashboard extends StatefulWidget {
  const LiptonAdminDashboard({super.key});

  @override
  State<LiptonAdminDashboard> createState() => _LiptonAdminDashboardState();
}

class _LiptonAdminDashboardState extends State<LiptonAdminDashboard> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    // Optimized: Faster animation durations to remove "buffering" feel
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _listController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    
    _fadeController.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient - Optimized with modern syntax
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.5, -0.6),
                  radius: 1.2,
                  colors: [
                    const Color(0xFF1B5E20).withValues(alpha: 0.1),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeader(context),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Tea Corner Insights"),
                          const SizedBox(height: 20),
                          _buildStatsGrid(),
                          const SizedBox(height: 32),
                          _buildSectionTitle("Pending Tea Orders"),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  _buildOrdersList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: "https://images.unsplash.com/photo-1544787210-2213d84ad96b?q=80&w=1963&auto=format&fit=crop",
              fit: BoxFit.cover,
              // Optimized: Added placeholder to prevent blank space while loading
              placeholder: (context, url) => Container(color: Colors.black12),
              errorWidget: (context, url, error) => Container(color: Colors.black),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.2), Colors.black],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "LIPTON",
                    style: GoogleFonts.monoton(
                      color: const Color(0xFFFFD700),
                      fontSize: 42,
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    "PREMIUM TEA HUB",
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.logout, color: Color(0xFFFFD700), size: 20),
          ),
          onPressed: () async {
            await context.read<AuthService>().logout();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 24, color: const Color(0xFFFFD700)),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("Total Tea Sold", "284 Cups", Icons.coffee_rounded),
        _buildStatCard("Today Revenue", "₹8,920", Icons.account_balance_wallet_outlined),
        _buildStatCard("Popular", "Green Tea", Icons.auto_awesome_outlined),
        _buildStatCard("Customers", "120+", Icons.people_outline),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text(label, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AnimatedBuilder(
              animation: _listController,
              builder: (context, child) {
                // Optimized: Lower offset for smoother, faster slide
                final double slide = (1.0 - CurvedAnimation(parent: _listController, curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut)).value) * 40.0;
                return Transform.translate(
                  offset: Offset(0, slide),
                  child: Opacity(
                    opacity: CurvedAnimation(parent: _listController, curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut)).value,
                    child: child,
                  ),
                );
              },
              child: _buildOrderCard(index),
            );
          },
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildOrderCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_food_beverage_outlined, color: Color(0xFFFFD700)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Order #LP-89${index + 1}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("1x Earl Grey Tea", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹120", style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("Pending", style: GoogleFonts.poppins(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
