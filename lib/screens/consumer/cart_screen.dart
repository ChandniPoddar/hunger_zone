import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hunger_zone/providers/cart_provider.dart';
import 'package:hunger_zone/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';
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

  Future<ApplicationMeta?> _showUpiAppSelector(
      BuildContext context, double amount, List<ApplicationMeta> apps) {
    return showModalBottomSheet<ApplicationMeta>(
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
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
                width: 40,
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
              const SizedBox(height: 4),
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
                            "Please install Google Pay, PhonePe, Paytm, or any other UPI app to complete your payment.",
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
                                  child: appMeta.iconImage(48),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  appMeta.upiApplication.getAppName(),
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

  Future<void> _startUpiTransaction(ApplicationMeta appMeta, double amount) async {
    try {
      final String transactionRef = "UPITXREF${DateTime.now().millisecondsSinceEpoch}";
      
      final UpiTransactionResponse response = await UpiPay.initiateTransaction(
        amount: amount.toStringAsFixed(2),
        app: appMeta.upiApplication,
        receiverName: AppConstants.receiverName,
        receiverUpiAddress: AppConstants.receiverUpiAddress,
        transactionRef: transactionRef,
        transactionNote: 'Order payment at Hunger Zone',
        merchantCode: AppConstants.merchantCode.isEmpty ? null : AppConstants.merchantCode,
      );

      debugPrint("UPI Response status: ${response.status}");
      debugPrint("UPI Response raw: ${response.rawResponse}");

      if (response.status == UpiTransactionStatus.success) {
        _handlePaymentSuccess(transactionRef);
      } else if (response.status == UpiTransactionStatus.submitted) {
        Fluttertoast.showToast(msg: "Transaction Submitted. Check status in your bank app.");
      } else {
        Fluttertoast.showToast(msg: "Payment Failed or Cancelled");
      }
    } catch (e) {
      debugPrint("UPI Error: $e");
      Fluttertoast.showToast(msg: "Transaction failed: $e");
    }
  }

  Future<void> _openCheckout(double amount) async {
    try {
      // Show loading while fetching installed UPI apps
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
          ),
        ),
      );

      final List<ApplicationMeta> appMetaList = await UpiPay.getInstalledUpiApplications();
      
      if (mounted) {
        Navigator.pop(context); // Dismiss loader
      }

      final selectedApp = await _showUpiAppSelector(context, amount, appMetaList);
      
      if (selectedApp != null) {
        await _startUpiTransaction(selectedApp, amount);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loader if still open
      }
      debugPrint("Checkout Error: $e");
      Fluttertoast.showToast(msg: "Error initializing payment: $e");
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

