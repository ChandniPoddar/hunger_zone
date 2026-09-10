import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hunger_zone/providers/cart_provider.dart';
import 'package:hunger_zone/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:upi_india/upi_india.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:hunger_zone/utils/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

  /// ─────────────────────────────────────────────
  /// Show Dynamic UPI QR Payment Sheet
  /// ─────────────────────────────────────────────
  void _showQrPaymentSheet(BuildContext context, double amount) {
    final String upiAddress = AppConstants.receiverUpiAddress.trim();
    final String receiverName = AppConstants.receiverName.trim();
    final String upiUri =
        "upi://pay?pa=$upiAddress&pn=${Uri.encodeComponent(receiverName)}&am=${amount.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent("Hunger Zone Order")}";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Header Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Color(0xFFFF5252),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Scan & Pay via UPI",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Scan from ANY phone using GPay, PhonePe, Paytm or BHIM",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // Amount Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    "₹${amount.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF5252),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Dynamic QR Code Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: upiUri,
                    version: QrVersions.auto,
                    size: 210.0,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF0F172A),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Receiver UPI Info + Copy Button
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: upiAddress));
                    Fluttertoast.showToast(msg: "UPI ID copied: $upiAddress");
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.account_balance_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(
                          "$receiverName ($upiAddress)",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.copy_rounded, size: 15, color: Color(0xFFFF5252)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Button 1: Confirm Payment (I have paid)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _handlePaymentSuccess("QR${DateTime.now().millisecondsSinceEpoch}");
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                    label: Text(
                      "I Have Paid • Confirm Order",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Emerald Green
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Button 2: Direct App Intent option
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _openDirectUpiAppSelector(amount);
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 17, color: Color(0xFF0F172A)),
                    label: Text(
                      "Open Installed UPI App Directly",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Button 3: Cash at Counter
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _handlePaymentSuccess("CASH${DateTime.now().millisecondsSinceEpoch}");
                  },
                  icon: const Icon(Icons.payments_outlined, size: 16, color: Color(0xFF64748B)),
                  label: Text(
                    "Or Pay Cash at Counter",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Direct UPI Apps Picker (Optional Intent launch)
  Future<void> _openDirectUpiAppSelector(double amount) async {
    final nav = Navigator.of(context);
    final currentContext = context;

    try {
      showDialog(
        context: currentContext,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
          ),
        ),
      );

      final List<UpiApp> appMetaList = await _upiIndia.getAllUpiApps();

      if (mounted) {
        nav.pop(); // Dismiss loader
      } else {
        return;
      }

      if (!mounted) return;
      final selectedApp = await _showUpiAppSelector(context, amount, appMetaList);

      if (selectedApp != null && mounted) {
        await _startUpiTransaction(selectedApp, amount);
      }
    } catch (e) {
      if (mounted) nav.pop();
      debugPrint("UPI app picker error: $e");
      Fluttertoast.showToast(msg: "Error opening UPI apps: $e");
    }
  }

  Future<UpiApp?> _showUpiAppSelector(
      BuildContext context, double amount, List<UpiApp> apps) {
    return showModalBottomSheet<UpiApp>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
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
              apps.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No UPI apps found on this device.",
                        style: GoogleFonts.poppins(color: Colors.grey.shade600),
                      ),
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
                          onTap: () => Navigator.pop(context, appMeta),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFBFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
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

  Future<void> _startUpiTransaction(UpiApp appMeta, double amount) async {
    try {
      final String transactionRef = "UPI${DateTime.now().millisecondsSinceEpoch}";
      
      final bool isPersonalVpa = AppConstants.receiverUpiAddress.contains('@oksbi') ||
          AppConstants.receiverUpiAddress.contains('@okaxis') ||
          AppConstants.receiverUpiAddress.contains('@okhdfcbank') ||
          AppConstants.receiverUpiAddress.contains('@okicici') ||
          AppConstants.receiverUpiAddress.contains('@ybl') ||
          AppConstants.receiverUpiAddress.contains('@ibl') ||
          AppConstants.receiverUpiAddress.contains('@paytm') ||
          AppConstants.merchantCode.isEmpty;

      final String? merchantId = isPersonalVpa ? null : AppConstants.merchantCode;

      final UpiResponse response = await _upiIndia.startTransaction(
        app: appMeta,
        receiverUpiId: AppConstants.receiverUpiAddress.trim(),
        receiverName: AppConstants.receiverName.trim(),
        transactionRefId: transactionRef,
        transactionNote: 'Hunger Zone Order',
        amount: amount,
        merchantId: merchantId,
      );

      debugPrint("UPI Response status: ${response.status}");

      if (response.status == UpiPaymentStatus.SUCCESS) {
        await _handlePaymentSuccess(transactionRef);
      } else if (response.status == UpiPaymentStatus.SUBMITTED) {
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
    _showQrPaymentSheet(context, amount);
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
          "userEmail": auth.email ?? "",
          "userPhone": auth.phoneNumber ?? "",
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
        if (mounted) {
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

