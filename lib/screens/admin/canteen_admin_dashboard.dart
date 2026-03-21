import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../auth/add_item_screen.dart';

class CanteenAdminDashboard extends StatefulWidget {
  const CanteenAdminDashboard({super.key});

  @override
  State<CanteenAdminDashboard> createState() => _CanteenAdminDashboardState();
}

class _CanteenAdminDashboardState extends State<CanteenAdminDashboard>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List orders = [];
  bool loading = true;

  /// CHANGE IF USING REAL DEVICE
  final String apiUrl = "http://10.0.2.2:5000/api/orders/canteen";

  @override
  void initState() {
    super.initState();

    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _fadeController.forward();

    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          orders = data;
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await http.put(
      Uri.parse("http://10.0.2.2:5000/api/orders/$id/status"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"status": status}),
    );
    fetchOrders();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending": return Colors.orange;
      case "Accepted": return Colors.blue;
      case "Preparing": return Colors.deepPurple;
      case "Ready": return Colors.teal;
      case "Completed": return Colors.green;
      case "Rejected": return Colors.red;
      default: return Colors.grey;
    }
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

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  double getTotalRevenue() {
    double total = 0;
    for (var order in orders) {
      total += (order['total'] ?? 0).toDouble();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {

    int totalOrders = orders.length;
    double totalRevenue = getTotalRevenue();

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFFD700),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        label: Text(
          "Add New Item",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
      body: Stack(
        children: [

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.5, 0.6),
                  radius: 1.2,
                  colors: [
                    const Color(0xFFD32F2F).withOpacity(0.1),
                    Colors.black
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

                          _buildSectionTitle("Operations Control"),
                          const SizedBox(height: 20),

                          _buildStatsGrid(totalOrders, totalRevenue),

                          const SizedBox(height: 32),

                          _buildSectionTitle("Live Food Queue"),
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
              imageUrl:
              "https://images.unsplash.com/photo-1556740734-7f9a2b7a0f4d?q=80&w=2070&auto=format&fit=crop",
              fit: BoxFit.cover,
            ),

            Container(
              color: Colors.black.withOpacity(0.4),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const SizedBox(height: 40),

                  Text(
                    "CANTEEN",
                    style: GoogleFonts.monoton(
                      color: const Color(0xFFFFD700),
                      fontSize: 42,
                      letterSpacing: 4,
                    ),
                  ),

                  Text(
                    "COMMAND CENTER",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
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
              color: Colors.black45,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700)),
            ),
            child: const Icon(Icons.logout, color: Color(0xFFFFD700), size: 20),
          ),
          onPressed: () async {
            await context.read<AuthService>().logout();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (r) => false,
            );
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

  Widget _buildStatsGrid(int total, double revenue) {

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [

        _buildStatCard("Total Revenue", "₹${revenue.toStringAsFixed(0)}",
            Icons.restaurant_menu_outlined),

        _buildStatCard("Orders", "$total",
            Icons.receipt_long_outlined),

        _buildStatCard("Kitchen", "Busy",
            Icons.fireplace_outlined),

        _buildStatCard("Inventory", "Live",
            Icons.inventory_2_outlined),

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

              Text(
                value,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),

              Text(
                label,
                style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {

    if (loading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (orders.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              "No orders yet",
              style: GoogleFonts.poppins(color: Colors.white38),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(

              (context, index) {
            final order = orders[index];
            return _buildOrderCard(order, index);
          },

          childCount: orders.length,
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map order, int index) {

    final List items = order['items'] ?? [];

    final String itemsSummary =
    items.map((i) => "${i['quantity']}x ${i['name']}").join(", ");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [

          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fastfood_outlined,
                color: Color(0xFFFFD700)),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Order ${order['orderId'] ?? "..."}",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),

                Text(
                  itemsSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text(order['userName'] ?? 'Guest',
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                    const SizedBox(width: 8),
                    const Icon(Icons.email, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(order['userEmail'] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              Text(
                "₹${order['total']}",
                style: GoogleFonts.poppins(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(order['status'] ?? "Pending").withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order['status'] ?? "Pending",
                  style: GoogleFonts.poppins(
                    color: getStatusColor(order['status'] ?? "Pending"),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  if ((order['status'] ?? "Pending") == "Pending")
                    actionBtn("Accept", Colors.blue, () => updateOrderStatus(order["_id"], "Accepted")),
                  if ((order['status'] ?? "Pending") == "Pending")
                    actionBtn("Reject", Colors.red, () => updateOrderStatus(order["_id"], "Rejected")),
                  if (order['status'] == "Accepted")
                    actionBtn("Prepare", Colors.deepPurple, () => updateOrderStatus(order["_id"], "Preparing")),
                  if (order['status'] == "Preparing")
                    actionBtn("Ready", Colors.teal, () => updateOrderStatus(order["_id"], "Ready")),
                  if (order['status'] == "Ready")
                    actionBtn("Complete", Colors.green, () => updateOrderStatus(order["_id"], "Completed")),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
