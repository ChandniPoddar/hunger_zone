import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class NescafeAdminDashboard extends StatefulWidget {
  const NescafeAdminDashboard({super.key});

  @override
  State<NescafeAdminDashboard> createState() => _NescafeAdminDashboardState();
}

class _NescafeAdminDashboardState extends State<NescafeAdminDashboard>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List orders = [];
  bool loading = true;

  final String apiUrl = "http://10.0.2.2:5000/orders";

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _fadeController.forward();

    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final res = await http.get(Uri.parse(apiUrl));

      if (res.statusCode == 200) {
        setState(() {
          orders = json.decode(res.body);
          loading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {

    await http.put(
      Uri.parse("http://10.0.2.2:5000/orders/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"status": status}),
    );

    fetchOrders();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Accepted":
        return Colors.blue;
      case "Preparing":
        return Colors.deepPurple;
      case "Ready":
        return Colors.teal;
      case "Completed":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    int totalOrders = orders.length;

    double revenue = 0;
    for (var o in orders) {
      revenue += (o["total"] ?? 0);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: loading
              ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFFD700),
            ),
          )
              : CustomScrollView(
            slivers: [

              _buildHeader(context),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      sectionTitle("Outlet Analytics"),
                      const SizedBox(height: 20),

                      statsGrid(totalOrders, revenue),

                      const SizedBox(height: 32),

                      sectionTitle("Recent Orders"),
                      const SizedBox(height: 16),

                    ],
                  ),
                ),
              ),

              buildOrders()

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      backgroundColor: Colors.transparent,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [

            CachedNetworkImage(
              imageUrl:
              "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085",
              fit: BoxFit.cover,
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black
                  ],
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const SizedBox(height: 40),

                  Text(
                    "NESCAFÉ",
                    style: GoogleFonts.monoton(
                      color: const Color(0xFFFFD700),
                      fontSize: 42,
                      letterSpacing: 4,
                    ),
                  ),

                  Text(
                    "ADMINISTRATION HUB",
                    style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 12,
                        letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [

        IconButton(
          icon: const Icon(Icons.logout, color: Color(0xFFFFD700)),
          onPressed: () async {

            await context.read<AuthService>().logout();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (r) => false,
            );
          },
        )
      ],
    );
  }

  Widget sectionTitle(String text) {
    return Row(
      children: [
        Container(width: 4, height: 24, color: const Color(0xFFFFD700)),
        const SizedBox(width: 12),
        Text(text,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget statsGrid(int totalOrders, double revenue) {

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [

        statCard("Revenue", "₹${revenue.toStringAsFixed(0)}"),
        statCard("Orders", "$totalOrders"),
        statCard("Queue", "Live"),
        statCard("Outlet", "Open"),

      ],
    );
  }

  Widget statCard(String label, String value) {

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(value,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),

          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.white38))

        ],
      ),
    );
  }

  Widget buildOrders() {

    if (orders.isEmpty) {
      return const SliverToBoxAdapter(
          child: Center(child: Text("No Orders")));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {

          final order = orders[index];
          final status = order["status"];

          final items = order["items"] as List;

          final itemsSummary =
          items.map((i) => "${i["quantity"]}x ${i["name"]}").join(", ");

          final statusColor = getStatusColor(status);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [

                const Icon(Icons.coffee_maker, color: Color(0xFFFFD700)),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(order["orderId"],
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),

                      Text(itemsSummary,
                          style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 12)),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    Text("₹${order["total"]}",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold)),

                    const SizedBox(height: 6),

                    Text(status,
                        style: GoogleFonts.poppins(
                            color: statusColor,
                            fontSize: 11)),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 6,
                      children: [

                        if (status == "Pending")
                          actionBtn("Accept", Colors.blue,
                                  () => updateOrderStatus(order["_id"], "Accepted")),

                        if (status == "Pending")
                          actionBtn("Reject", Colors.red,
                                  () => updateOrderStatus(order["_id"], "Rejected")),

                        if (status == "Accepted")
                          actionBtn("Prepare", Colors.deepPurple,
                                  () => updateOrderStatus(order["_id"], "Preparing")),

                        if (status == "Preparing")
                          actionBtn("Ready", Colors.teal,
                                  () => updateOrderStatus(order["_id"], "Ready")),

                        if (status == "Ready")
                          actionBtn("Complete", Colors.green,
                                  () => updateOrderStatus(order["_id"], "Completed")),

                      ],
                    )
                  ],
                )
              ],
            ),
          );

        }, childCount: orders.length),
      ),
    );
  }

  Widget actionBtn(String text, Color color, VoidCallback onTap) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color)),
        child: Text(text,
            style: GoogleFonts.poppins(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
