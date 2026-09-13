import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hunger_zone/providers/cart_provider.dart';
import 'package:hunger_zone/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:upi_india/upi_india.dart';
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

  final String apiUrl = "${AppConstants.baseUrl}/api/orders";
  final UpiIndia _upiIndia = UpiIndia();
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<UpiApp?> _showUpiAppSelector(
      BuildContext context, double amount, List<UpiApp> apps) {
    return showModalBottomSheet<UpiApp>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 25,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Header
              Text(
                "Select UPI Payment App",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Choose an app to pay ₹${amount.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),
              // Apps Content
              apps.isEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No UPI Apps Found",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Please install Google Pay, PhonePe, Paytm, BHIM, or any other UPI app to complete your payment.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: apps.length,
                      itemBuilder: (context, index) {
                        final appMeta = apps[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context, appMeta);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFBFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade100,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    appMeta.icon,
                                    width: 48,
                                    height: 48,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  appMeta.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleUpiPaymentFlow(double amount) async {
    if (_isProcessingPayment) return;
    setState(() => _isProcessingPayment = true);

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthService>();
    final outlet = widget.outletName ?? cart.currentOutletName ?? 'Canteen';
    final vendorId = cart.currentVendorId ?? CartProvider.getNormalizedVendorId(outlet);

    // Show initial processing loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
        ),
      ),
    );

    try {
      // 1. Create order on backend (Backend validates vendor and calculates total server-side)
      final items = cart.items.values.map((item) {
        return {
          "id": item.foodItem.id,
          "name": item.foodItem.name,
          "quantity": item.quantity,
          "price": item.foodItem.price,
        };
      }).toList();

      final orderRes = await http.post(
        Uri.parse("${AppConstants.baseUrl}/api/orders"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "vendorId": vendorId,
          "outlet": outlet,
          "userName": auth.name ?? "Guest",
          "userEmail": auth.email ?? "",
          "userPhone": auth.phoneNumber ?? "",
          "paymentMethod": "UPI",
          "items": items,
        }),
      );

      final orderData = jsonDecode(orderRes.body);
      if (orderRes.statusCode != 200 && orderRes.statusCode != 201) {
        if (mounted) Navigator.pop(context); // Dismiss loader
        setState(() => _isProcessingPayment = false);
        Fluttertoast.showToast(msg: orderData["message"] ?? "Failed to create order");
        return;
      }

      final createdOrder = orderData["order"];
      final String orderId = createdOrder["orderId"];

      // 2. Request dynamic payment intent from backend for this vendor & order
      final intentRes = await http.post(
        Uri.parse("${AppConstants.baseUrl}/api/payment/create-intent"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "orderId": orderId,
          "vendorId": vendorId,
        }),
      );

      final intentData = jsonDecode(intentRes.body);
      if (intentRes.statusCode != 200) {
        if (mounted) Navigator.pop(context); // Dismiss loader
        setState(() => _isProcessingPayment = false);
        Fluttertoast.showToast(
          msg: intentData["message"] ?? "Payment is currently unavailable for this vendor.",
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }

      // 3. Fetch installed UPI apps
      final List<UpiApp> appMetaList = await _upiIndia.getAllUpiApps();

      if (mounted) {
        Navigator.pop(context); // Dismiss loader
      }

      if (!mounted) {
        setState(() => _isProcessingPayment = false);
        return;
      }

      // 4. Prompt user to select their UPI app
      final finalAmount = (intentData["amount"] as num).toDouble();
      final selectedApp = await _showUpiAppSelector(context, finalAmount, appMetaList);

      if (selectedApp == null) {
        setState(() => _isProcessingPayment = false);
        return;
      }

      // 5. Start UPI Intent using ONLY backend-supplied vendor credentials
      final UpiResponse response = await _upiIndia.startTransaction(
        app: selectedApp,
        receiverUpiId: intentData["receiverUpiId"],
        receiverName: intentData["receiverName"],
        transactionRefId: intentData["transactionRef"],
        transactionNote: 'Hunger Zone Order #$orderId',
        amount: finalAmount,
        merchantId: intentData["merchantId"],
      );

      debugPrint("UPI Response status: ${response.status}");
      debugPrint("UPI Response approvalRef: ${response.approvalRefNo}");

      // 6. Verify and update payment status on backend
      String statusStr = "FAILURE";
      if (response.status == UpiPaymentStatus.SUCCESS) {
        statusStr = "SUCCESS";
      } else if (response.status == UpiPaymentStatus.SUBMITTED) {
        statusStr = "SUBMITTED";
      }

      await http.post(
        Uri.parse("${AppConstants.baseUrl}/api/payment/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "orderId": orderId,
          "transactionRef": intentData["transactionRef"],
          "status": statusStr,
          "approvalRefNo": response.approvalRefNo,
        }),
      );

      if (response.status == UpiPaymentStatus.SUCCESS) {
        cart.clearCart();
        NotificationService.showNotification(
          id: 1,
          title: "Payment Successful!",
          body: "Your order for $outlet has been placed.",
        );
        Fluttertoast.showToast(msg: "Payment successful! Order placed.");
        if (mounted) {
          Navigator.pop(context);
        }
      } else if (response.status == UpiPaymentStatus.SUBMITTED) {
        cart.clearCart();
        Fluttertoast.showToast(msg: "Transaction Submitted. Check status in your bank app.");
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        Fluttertoast.showToast(msg: "Payment Failed or Cancelled");
      }
    } catch (e) {
      debugPrint("UPI Checkout error: $e");
      if (mounted) {
        try { Navigator.pop(context); } catch (_) {}
      }
      Fluttertoast.showToast(msg: "Transaction error: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  Future<void> _showPaymentMethodSelector(double amount) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Choose Payment Method",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    "₹${amount.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Select how you want to complete this order",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 22),

              // Option 1: UPI / Online Payment
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _handleUpiPaymentFlow(amount);
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                        const Color(0xFFFF8E53).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pay Online (Google Pay / UPI)",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Google Pay, PhonePe, Paytm, BHIM",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFFFF6B6B),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Option 2: Pay at Counter
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _handleCashAtCounter(amount);
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.payments_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pay at Counter (Cash)",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Pay with cash when picking up food",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleCashAtCounter(double amount) async {
    if (_isProcessingPayment) return;
    setState(() => _isProcessingPayment = true);

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthService>();
    final outlet = widget.outletName ?? cart.currentOutletName ?? 'Canteen';
    final vendorId = cart.currentVendorId ?? CartProvider.getNormalizedVendorId(outlet);

    try {
      final items = cart.items.values.map((item) {
        return {
          "id": item.foodItem.id,
          "name": item.foodItem.name,
          "quantity": item.quantity,
          "price": item.foodItem.price,
        };
      }).toList();

      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "vendorId": vendorId,
          "outlet": outlet,
          "userName": auth.name ?? "Guest",
          "userEmail": auth.email ?? "",
          "userPhone": auth.phoneNumber ?? "",
          "paymentMethod": "Cash at Counter",
          "items": items,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final total = (data["order"]?["total"] ?? amount).toDouble();
        cart.clearCart();
        NotificationService.showNotification(
          id: 1,
          title: "Order Placed!",
          body: "Your order for $outlet has been placed. Please pay ₹${total.toStringAsFixed(0)} at the counter.",
        );
        Fluttertoast.showToast(
          msg: "Order placed! Please pay ₹${total.toStringAsFixed(0)} at counter.",
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        Fluttertoast.showToast(msg: data["message"] ?? "Failed to save order");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Server error saving order: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
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
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
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
                        onPressed: _isProcessingPayment ? null : () => _showPaymentMethodSelector(totalAmount),
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

