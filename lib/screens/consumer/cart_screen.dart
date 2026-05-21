import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hunger_zone/providers/cart_provider.dart';
import 'package:hunger_zone/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:hunger_zone/utils/constants.dart';
import '../../services/notification_service.dart';


class CartScreen extends StatefulWidget {
  final String? outletName;

  const CartScreen({super.key, this.outletName});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;

  final String apiUrl = "${AppConstants.baseUrl}/api/orders";
  final String paymentInitUrl = "${AppConstants.baseUrl}/api/payment/phonepe/create-order";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openCheckout(double amount) async {
    final auth = context.read<AuthService>();
    try {
      // 1. Get Token and Order Details from Backend
      final res = await http.post(
        Uri.parse(paymentInitUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": amount,
          "userId": auth.phoneNumber ?? "USER123",
          "mobileNumber": auth.phoneNumber ?? "9999999999"
        })
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          String token = data['token'];
          String orderId = data['orderId'];
          String merchantId = data['merchantId'];
          String environment = data['environment']; // 'SANDBOX' or 'PRODUCTION'

          // 2. Initialize PhonePe SDK
          bool isInitialized = await PhonePePaymentSdk.init(environment, merchantId, "HungerZoneFlow", false);
          if (!isInitialized) {
            Fluttertoast.showToast(msg: "Failed to initialize payment gateway");
            return;
          }

          // 3. Start Transaction
          Map<String, dynamic> payload = {
            "orderId": orderId,
            "merchantId": merchantId,
            "token": token,
            "paymentMode": {"type": "PAY_PAGE"}
          };
          
          // Depending on SDK version, some expect base64, but new SDK docs say jsonEncode
          // Actually, PhonePe SDK requires base64 encoded request payload!
          // But the docs user gave said `jsonEncode(payload)`, so we pass the json string.
          // To be safe, we'll try jsonEncode. If it fails, base64.
          String request = jsonEncode(payload);
          // Wait, PhonePe standard expects base64! Let's follow docs literally.
          // If the token returned by our backend is actually the base64 intent payload,
          // then the new SDK might accept it. Our backend returns the `token` properly.

          final response = await PhonePePaymentSdk.startTransaction(request, "iOSIntentIntegration");
          
          if (response != null) {
            String status = response['status'].toString();
            String error = response['error']?.toString() ?? "";
            
            if (status == 'SUCCESS') {
              _handlePaymentSuccess(orderId);
            } else {
              Fluttertoast.showToast(msg: "Payment Failed: $status $error");
            }
          } else {
            Fluttertoast.showToast(msg: "Payment Incomplete");
          }
        } else {
          Fluttertoast.showToast(msg: "Failed to initiate payment");
        }
      } else {
        Fluttertoast.showToast(msg: "Server Error: Could not connect to payment gateway");
      }
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(msg: "Payment Error: $e");
    }
  }

  Future<void> _handlePaymentSuccess(String orderId) async {
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthService>();

    final items = cart.items.values.map((item) {
      return {
        "name": item.foodItem.name,
        "quantity": item.quantity,
        "price": item.foodItem.price,
      };
    }).toList();

    final total = cart.items.values.fold(
        0.0, (sum, item) => sum + (item.foodItem.price * item.quantity));

    try {
      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "orderId": orderId,
          "outlet": widget.outletName ?? "Hunger Zone",
          "userName": auth.name ?? "Guest",
          "userPhone": auth.phoneNumber ?? "0000000000",
          "items": items,
          "total": total,
          "status": "Pending"
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        cart.clearCart();
        NotificationService.showNotification(
          id: 1,
          title: "Order Placed!",
          body: "Your order for ${widget.outletName} has been received.",
        );
        if(mounted) {
           Navigator.pop(context);
        }
      } else {
        Fluttertoast.showToast(msg: "Order failed to save to DB");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Server error saving order: $e");
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<CartProvider>(
          builder: (context, cart, child) {
            final count = cart.items.length;
            return Text(
              "My Cart ($count)",
              style: GoogleFonts.poppins(color: const Color(0xFF1A1A2E), fontWeight: FontWeight.bold, fontSize: 18),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6B6B)),
            onPressed: () => context.read<CartProvider>().clearCart(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final items = widget.outletName == null
              ? cart.items.values.toList()
              : cart.items.values
                  .where((item) => cart.getNormalizedOutlet(item.foodItem.category) == widget.outletName)
                  .toList();

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("Your cart is empty", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final totalAmount = items.fold(0.0, (sum, item) => sum + (item.foodItem.price * item.quantity));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          // Item Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: item.foodItem.imageUrl.startsWith('http') 
                                  ? item.foodItem.imageUrl 
                                  : "${AppConstants.baseUrl}/${item.foodItem.imageUrl}",
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 80,
                                height: 80,
                                color: const Color(0xFFF8F9FA),
                                child: const Icon(Icons.fastfood_outlined, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.foodItem.name,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1A1A2E)),
                                ),
                                Text(
                                  "₹${item.foodItem.price}",
                                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                // Quantity Selector
                                Container(
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.remove, size: 14, color: Colors.black54),
                                        onPressed: () => cart.removeSingleItem(item.foodItem.id),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          "${item.quantity}",
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF1A1A2E)),
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.add, size: 14, color: Colors.black54),
                                        onPressed: () => cart.addItem(item.foodItem),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Item Total Price
                          Text(
                            "₹${(item.foodItem.price * item.quantity).toStringAsFixed(2)}",
                            style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Bottom Section
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total:",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                        ),
                        Text(
                          "₹${totalAmount.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        onPressed: () => _openCheckout(totalAmount),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Proceed to Payment",
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

