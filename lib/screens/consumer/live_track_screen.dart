import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:hunger_zone/utils/constants.dart';
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
    final userEmail = auth.email ?? auth.phoneNumber;
    if (userEmail == null || userEmail.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final encodedEmail = Uri.encodeComponent(userEmail.toLowerCase().trim());
      // First try email route
      var res = await http.get(
        Uri.parse("${AppConstants.baseUrl}/api/orders/user/email/$encodedEmail"),
      );

      // Fallback to legacy user route if empty or 404
      if (res.statusCode != 200 || json.decode(res.body).isEmpty) {
        final legacyRes = await http.get(
          Uri.parse("${AppConstants.baseUrl}/api/orders/user/$encodedEmail"),
        );
        if (legacyRes.statusCode == 200 && json.decode(legacyRes.body).isNotEmpty) {
          res = legacyRes;
        }
      }

      if (res.statusCode == 200) {
        final List newOrders = json.decode(res.body);

        if (mounted) {
          setState(() {
            _orders = newOrders;
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
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFB),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Live Track", 
          style: GoogleFonts.poppins(
            color: Colors.black, 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFF6B6B),
        onRefresh: _fetchMyOrders,
        child: _loading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
          : _orders.isEmpty
            ? Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Center(child: Text("📦", style: TextStyle(fontSize: 50))),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        "No active orders found", 
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final List items = order["items"] ?? [];
                  final itemsSummary = items.map((i) => "${i["quantity"]}x ${i["name"]}").join(", ");
                  final statusColor = _getStatusColor(order["status"] ?? "Pending");

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order["outlet"] ?? "Canteen",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order["status"] ?? "Pending",
                                style: GoogleFonts.poppins(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Order ID: #${order["orderId"] ?? "N/A"}",
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                        ),
                        const Divider(height: 25),
                        Text(
                          itemsSummary,
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Paid",
                              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                            ),
                            Text(
                              "₹${order["total"] ?? 0}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFFFF6B6B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
