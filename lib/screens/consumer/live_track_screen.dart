import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:hunger_zone/utils/constants.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

class LiveTrackScreen extends StatefulWidget {
  const LiveTrackScreen({super.key});

  @override
  State<LiveTrackScreen> createState() => _LiveTrackScreenState();
}

class _LiveTrackScreenState extends State<LiveTrackScreen> {
  bool _loading = true;
  List _orders = [];
  Timer? _timer;
  Map<String, String> _previousStatuses = {};

  @override
  void initState() {
    super.initState();
    _fetchMyOrders();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchMyOrders(isPolling: true);
    });
  }

  Future<void> _fetchMyOrders({bool isPolling = false}) async {
    final auth = context.read<AuthService>();
    final phone = auth.phoneNumber;
    if (phone == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final res = await http.get(Uri.parse("${AppConstants.baseUrl}/api/orders/user/$phone"));
      if (res.statusCode == 200) {
        final List newOrders = json.decode(res.body);
        
        if (isPolling) {
          _checkStatusChanges(newOrders);
        } else {
          // Initialize previous statuses on first load
          for (var order in newOrders) {
            _previousStatuses[order['orderId']] = order['status'] ?? "Pending";
          }
        }

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

  void _checkStatusChanges(List newOrders) {
    for (var order in newOrders) {
      final orderId = order['orderId'];
      final newStatus = order['status'] ?? "Pending";
      final oldStatus = _previousStatuses[orderId];

      if (oldStatus != null && oldStatus != newStatus) {
        // Status changed!
        NotificationService.showNotification(
          id: orderId.hashCode,
          title: "Order Update",
          body: "Your order for ${order['outlet']} is now $newStatus",
        );
      }
      _previousStatuses[orderId] = newStatus;
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
    final primaryColor = const Color(0xFFFF6B6B);

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
          )
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
        : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("📦", style: TextStyle(fontSize: 50)),
                  const SizedBox(height: 16),
                  Text(
                    "No active orders found", 
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)
                  ),
                ],
              )
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
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order['outlet'] ?? 'Outlet', 
                            style: GoogleFonts.poppins(
                              color: Colors.black, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 16
                            )
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1), 
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text(
                              order["status"] ?? "Pending", 
                              style: GoogleFonts.poppins(
                                color: statusColor, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 11
                              )
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Items: $itemsSummary", 
                        style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13)
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order ID: ${order['orderId'] ?? ''}", 
                            style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 10)
                          ),
                          Text(
                            "₹${order['total']}", 
                            style: GoogleFonts.poppins(
                              color: primaryColor, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 18
                            )
                          ),
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
