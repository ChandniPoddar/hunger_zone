import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hunger_zone/utils/constants.dart';
import '../../services/auth_service.dart';
import '../../providers/outlet_provider.dart';
import '../auth/login_screen.dart';
import '../auth/add_item_screen.dart';
import 'manage_items_screen.dart';

class NescafeAdminDashboard extends StatefulWidget {
  const NescafeAdminDashboard({super.key});

  @override
  State<NescafeAdminDashboard> createState() => _NescafeAdminDashboardState();
}

class _NescafeAdminDashboardState extends State<NescafeAdminDashboard> with TickerProviderStateMixin {
  List orders = [];
  bool loading = true;
  int _currentTab = 0;

  final Color primaryCoral = const Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse("${AppConstants.baseUrl}/api/orders/nescafe"));
      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    try {
      final response = await http.put(
        Uri.parse("${AppConstants.baseUrl}/api/orders/$id/status"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"status": status}),
      );
      if (response.statusCode == 200) {
        await fetchOrders();
      }
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalRevenue = orders.fold(0.0, (sum, item) => sum + (item['total'] ?? 0));
    int pendingCount = orders.where((o) => o['status'] == 'Pending').length;
    int kitchenCount = orders.where((o) => o['status'] == 'Preparing' || o['status'] == 'Accepted').length;

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          return true;
        } else {
          SystemNavigator.pop();
          return false;
        }
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryCoral,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen(outlet: 'Nescafe'))),
        label: Text("Add Item", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBusinessOverview(),
                  const SizedBox(height: 25),
                  _buildStatsGrid(totalRevenue, pendingCount, kitchenCount),
                  const SizedBox(height: 30),
                  _buildTabs(),
                  const SizedBox(height: 20),
                  _buildOrdersList(),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    SystemNavigator.pop();
                  }
                },
              ),
              Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(Icons.logout_rounded, color: primaryCoral),
                  onPressed: () async {
                    await context.read<AuthService>().logout();
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: primaryCoral, borderRadius: BorderRadius.circular(20)),
            child: Text("Nescafe Hub", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Text(
            "Partner Dashboard",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessOverview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Business Overview", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
        Consumer<OutletProvider>(
          builder: (context, outletProvider, child) {
            bool isOpen = outletProvider.isOpen('Nescafe');
            return Row(
              children: [
                Text(isOpen ? "OPEN" : "CLOSED", style: GoogleFonts.poppins(color: isOpen ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 8),
                Switch(
                  value: isOpen,
                  onChanged: (val) => outletProvider.toggleStatus('Nescafe'),
                  activeColor: Colors.green,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsGrid(double revenue, int pending, int kitchen) {
    return Row(
      children: [
        Expanded(child: _buildStatCard("Revenue", "₹${revenue.toStringAsFixed(0)}", Icons.account_balance_wallet, Colors.teal)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Pending", "$pending", Icons.timer, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Kitchen", "$kitchen", Icons.receipt, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageItemsScreen(category: 'Nescafe'))),
            child: _buildStatCard("Menu", "Edit", Icons.restaurant_menu, primaryCoral),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: GoogleFonts.poppins(color: Colors.black38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _buildTabItem("Live Kitchen", 0),
        const SizedBox(width: 30),
        _buildTabItem("History", 1),
      ],
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool active = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: active ? FontWeight.bold : FontWeight.w500, color: active ? primaryCoral : Colors.black38)),
          if (active) Container(margin: const EdgeInsets.only(top: 4), height: 3, width: 40, decoration: BoxDecoration(color: primaryCoral, borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (loading) return const Center(child: CircularProgressIndicator());
    List filteredOrders = _currentTab == 0 ? orders.where((o) => o['status'] != 'Completed' && o['status'] != 'Rejected').toList() : orders.where((o) => o['status'] == 'Completed' || o['status'] == 'Rejected').toList();
    if (filteredOrders.isEmpty) return Center(child: Text("No orders found", style: GoogleFonts.poppins(color: Colors.black38)));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) => _buildOrderCard(filteredOrders[index]),
    );
  }

  Widget _buildOrderCard(Map order) {
    final List items = order['items'] ?? [];
    final String itemsSummary = items.map((i) => "${i['quantity']}x ${i['name']}").join(", ");
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)), child: Text("Order #${order['orderId'] ?? '...'}", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold))),
              Text(order['status'] ?? "Pending", style: GoogleFonts.poppins(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: (items.isNotEmpty && items[0]['imageUrl'] != null && items[0]['imageUrl'].toString().isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: (items[0]['imageUrl']?.toString() ?? '').startsWith('http')
                            ? items[0]['imageUrl'].toString()
                            : "${AppConstants.baseUrl}${items[0]['imageUrl']?.toString().startsWith('/') == true ? '' : '/'}${items[0]['imageUrl']}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(width: 50, height: 50, color: Colors.grey[100], child: const Icon(Icons.fastfood_outlined, color: Colors.black26)),
                      )
                    : Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.coffee, color: Colors.black45)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itemsSummary, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 12, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(order['userName'] ?? 'Guest', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                        const SizedBox(width: 10),
                        const Icon(Icons.phone, size: 12, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(order['userPhone'] ?? '', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
              Text("₹${order['total']}", style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 18, color: primaryCoral)),
            ],
          ),
          const SizedBox(height: 20),
          if (order['status'] == 'Pending' || order['status'] == 'Accepted' || order['status'] == 'Preparing' || order['status'] == 'Ready')
            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                onPressed: () async {
                  String nextStatus = order['status'] == 'Pending' ? 'Accepted' : order['status'] == 'Accepted' ? 'Preparing' : order['status'] == 'Preparing' ? 'Ready' : 'Completed';
                  await updateOrderStatus(order['_id'], nextStatus);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: order['status'] == 'Pending' ? const Color(0xFFFF6B6B) : 
                           order['status'] == 'Accepted' ? Colors.blue : 
                           order['status'] == 'Preparing' ? Colors.amber : Colors.green, 
                    width: 1.5
                  ), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: Text(
                  order['status'] == 'Pending' ? 'Accept Order' : 
                  order['status'] == 'Accepted' ? 'Start Preparing' : 
                  order['status'] == 'Preparing' ? 'Mark Ready' : 'Complete Order', 
                  style: GoogleFonts.poppins(
                    color: order['status'] == 'Pending' ? const Color(0xFFFF6B6B) : 
                           order['status'] == 'Accepted' ? Colors.blue : 
                           order['status'] == 'Preparing' ? Colors.amber : Colors.green, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ),
        ],
      ),
    );
  }
}

