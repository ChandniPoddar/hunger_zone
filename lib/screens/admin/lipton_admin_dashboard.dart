import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.5, -0.6),
                  radius: 1.2,
                  colors: [const Color(0xFF1B5E20).withValues(alpha: 0.1), Colors.black],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('orders')
                    .where('outlet', isEqualTo: 'Lipton')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  int totalOrders = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  double dailyRevenue = 0;
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      dailyRevenue += (doc.data() as Map<String, dynamic>)['total'] ?? 0.0;
                    }
                  }

                  return CustomScrollView(
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
                              _buildStatsGrid(totalOrders, dailyRevenue),
                              const SizedBox(height: 32),
                              _buildSectionTitle("Live Tea Queue"),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      _buildOrdersList(snapshot),
                    ],
                  );
                }
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
            ),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.2), Colors.black]))),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text("LIPTON", style: GoogleFonts.monoton(color: const Color(0xFFFFD700), fontSize: 42, letterSpacing: 4)),
                  Text("PREMIUM TEA HUB", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w500)),
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
            decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5))),
            child: const Icon(Icons.logout, color: Color(0xFFFFD700), size: 20),
          ),
          onPressed: () async {
            await context.read<AuthService>().logout();
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
        Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatsGrid(int total, double revenue) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("Daily Revenue", "₹${revenue.toStringAsFixed(0)}", Icons.account_balance_wallet_outlined),
        _buildStatCard("Total Tea", "$total", Icons.coffee_rounded),
        _buildStatCard("Service", "Fast", Icons.speed_outlined),
        _buildStatCard("Customers", "Live", Icons.people_outline),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
          ]),
        ],
      ),
    );
  }

  Widget _buildOrdersList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.only(top: 40), child: Text("No orders yet", style: GoogleFonts.poppins(color: Colors.white38)))));
    }
    final docs = snapshot.data!.docs;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
        final order = docs[index].data() as Map<String, dynamic>;
        return _buildOrderCard(order, index);
      }, childCount: docs.length)),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, int index) {
    final List items = order['items'] ?? [];
    final String itemsSummary = items.map((i) => "${i['quantity']}x ${i['name']}").join(", ");
    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Row(children: [
        Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFFFD700).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.emoji_food_beverage_outlined, color: Color(0xFFFFD700))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Order ${order['orderId']?.toString().split('-').last ?? '...'}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(itemsSummary, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text("₹${order['total']}", style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(order['status'] ?? "Pending", style: GoogleFonts.poppins(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold))),
        ]),
      ]),
    );
  }
}
