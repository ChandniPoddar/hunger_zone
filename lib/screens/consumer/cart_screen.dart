import 'dart:io'; // ✅ Platform check

import 'package:flutter/material.dart';
import 'package:ggi_canteen/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;

  // 🔑 Your Razorpay TEST Key ID
  final String razorpayKey = 'rzp_test_SAodWBg2uq2dkh';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // 🔓 Open Razorpay Checkout (NO SERVER)
  void _openCheckout(double amount) {
    var options = {
      'key': razorpayKey,
      'amount': (amount * 100).toInt(), // INR → paise
      'name': 'GGI Canteen',
      'description': 'Food Order Payment',
      'prefill': {
        'contact': '9999999999',
        'email': 'test@example.com',
      },
      'external': {
        'wallets': ['PAYTM'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay error: $e');
    }
  }

  // ✅ Payment Success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful! Order Placed.'),
      ),
    );

    Navigator.pop(context);
  }

  // ❌ Payment Failed
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment Failed: ${response.code} - ${response.message}',
        ),
      ),
    );
  }

  // 💼 External Wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
        Text('External Wallet Selected: ${response.walletName}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.itemCount == 0) {
            return const Center(
              child: Text('Your cart is empty!'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem =
                    cart.items.values.toList()[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                        cartItem.foodItem.imageUrl.isNotEmpty
                            ? NetworkImage(
                            cartItem.foodItem.imageUrl)
                            : null,
                        child: cartItem.foodItem.imageUrl.isEmpty
                            ? const Icon(Icons.fastfood)
                            : null,
                      ),
                      title: Text(cartItem.foodItem.name),
                      subtitle: Text(
                        '₹${cartItem.foodItem.price.toStringAsFixed(2)} x ${cartItem.quantity}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹${cartItem.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              cart.removeSingleItem(
                                  cartItem.foodItem.id);
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.green),
                            onPressed: () {
                              cart.addItem(cartItem.foodItem);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /// -------- CHECKOUT SECTION --------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${cart.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (Platform.isAndroid ||
                              Platform.isIOS) {
                            _openCheckout(cart.totalAmount);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Razorpay works only on Android & iOS'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
                        ),
                        child: const Text(
                          'Checkout with Razorpay',
                          style: TextStyle(fontSize: 16),
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
