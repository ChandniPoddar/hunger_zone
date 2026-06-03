import 'package:hunger_zone/utils/color_extension.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:hunger_zone/utils/constants.dart';
import '../../services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loading = true;
  List _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchMyOrders();
  }

  Future<void> _fetchMyOrders() async {
    final auth = context.read<AuthService>();
    final phone = auth.phoneNumber;
    if (phone == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse("${AppConstants.baseUrl}/api/orders/user/$phone"),
      );
      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            List allOrders = json.decode(res.body);
            _orders = allOrders
                .where(
                  (o) =>
                      o['status'] == 'Completed' || o['status'] == 'Rejected',
                )
                .toList();
            // Sort by latest order first
            _orders.sort((a, b) => b['orderId'].compareTo(a['orderId']));
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
      case "Pending":
        return Color(0xFFF9CA24); // Yellow
      case "Accepted":
        return Color(0xFF45B7D1); // Blue
      case "Preparing":
        return Color(0xFF45B7D1); // Blue
      case "Ready":
        return Color(0xFF4ECDC4); // Teal
      case "Completed":
        return Color(0xFF4ECDC4); // Teal
      case "Rejected":
        return Color(0xFFFF6B6B); // Red
      default:
        return context.subTextColor; // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor, // Light Gray
      appBar: AppBar(
        backgroundColor: context.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "History",
          style: TextStyle(
            color: context.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: context.borderColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No completed orders found",
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Your previous orders will appear here.",
                    style: TextStyle(color: context.subTextColor, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final List items = order["items"] ?? [];
                final itemsSummary = items
                    .map((i) => "${i["quantity"]}x ${i["name"]}")
                    .join("\n");
                final statusColor = _getStatusColor(
                  order["status"] ?? "Completed",
                );

                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.bgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.storefront_rounded,
                                  color: Color(0xFFFF6B6B),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                order['outlet'] ?? 'Hunger Zone',
                                style: TextStyle(
                                  color: context.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              order["status"] ?? "Completed",
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Divider(color: context.borderColor, height: 1),
                      SizedBox(height: 16),
                      Text(
                        "Items",
                        style: TextStyle(
                          color: context.subTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        itemsSummary,
                        style: TextStyle(
                          color: context.textColor,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Order ID",
                                  style: TextStyle(
                                    color: context.subTextColor,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  order['orderId'] ?? '',
                                  style: TextStyle(
                                    color: context.textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Total",
                                  style: TextStyle(
                                    color: context.subTextColor,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  "₹${order['total']}",
                                  style: TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
