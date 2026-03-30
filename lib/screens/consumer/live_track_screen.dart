import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:ggi_canteen/utils/constants.dart';
import '../../services/auth_service.dart';

class LiveTrackScreen extends StatefulWidget {
  const LiveTrackScreen({super.key});

  @override
  State<LiveTrackScreen> createState() => _LiveTrackScreenState();
}

class _LiveTrackScreenState extends State<LiveTrackScreen> {
  bool _loading = true;
  List _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchMyOrders();
  }

  Future<void> _fetchMyOrders() async {
    final auth = context.read<AuthService>();
    final email = auth.email;
    if (email == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final res = await http.get(Uri.parse("${AppConstants.baseUrl}/api/orders/user/$email"));
      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            _orders = json.decode(res.body);
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _getStatusColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter orders if needed, we assume backend gives only our orders
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Live Track", style: GoogleFonts.poppins(color: theme.primaryColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: _loading 
        ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
        : _orders.isEmpty
          ? Center(child: Text("No active orders found", style: GoogleFonts.poppins(color: Colors.white38)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final List items = order["items"] ?? [];
                final itemsSummary = items.map((i) => "${i["quantity"]}x ${i["name"]}").join("\n");
                final statusColor = _getStatusColor(order["status"] ?? "Pending");

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color ?? const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Outlet: ${order['outlet'] ?? ''}", style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                            child: Text(order["status"] ?? "Pending", style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 12),
                      Text("Items:", style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(itemsSummary, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order ID: ${order['orderId'] ?? ''}", style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10)),
                          Text("Total: ₹${order['total']}", style: GoogleFonts.poppins(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
