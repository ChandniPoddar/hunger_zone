import 'dart:io'; // ✅ REQUIRED for platform check

import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:ggi_canteen/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.itemCount == 0) {
            return const Center(child: Text('Your cart is empty!'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.items.values.toList()[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: cartItem.foodItem.imageUrl.isNotEmpty
                            ? NetworkImage(cartItem.foodItem.imageUrl)
                            : null,
                        child: cartItem.foodItem.imageUrl.isEmpty
                            ? const Icon(Icons.fastfood)
                            : null,
                      ),
                      title: Text(cartItem.foodItem.name),
                      subtitle: Text(
                        '\$${cartItem.foodItem.price.toStringAsFixed(2)} x ${cartItem.quantity}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              cart.removeSingleItem(
                                  cartItem.foodItem.id);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
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

              /// -------- BOTTOM CHECKOUT SECTION --------
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
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
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
                          /// ✅ PLATFORM CHECK (CRITICAL FIX)
                          if (Platform.isAndroid ||
                              Platform.isIOS) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    UsePaypal(
                                      sandboxMode: true,
                                      clientId:
                                      "AYaXRGCcUOQDby_OExOYdRBweH91jQ4BcUIwiUPQWS4kjwIfT-LNNv9YHk6uYUsob_0xuSS3xp8UFgw1",
                                      secretKey:
                                      "EIkXOXJpiB--roPc32vXl9BqfUuOfyM7_LFOUdSIzkEp4ZvUMGM80y99q2czjPmhhAhReV4Za25f_xdD",
                                      returnURL:
                                      "https://samplesite.com/return",
                                      cancelURL:
                                      "https://samplesite.com/cancel",
                                      transactions: [
                                        {
                                          "amount": {
                                            "total": cart.totalAmount
                                                .toStringAsFixed(2),
                                            "currency": "USD",
                                            "details": {
                                              "subtotal": cart.totalAmount
                                                  .toStringAsFixed(2),
                                              "shipping": '0',
                                              "shipping_discount": 0
                                            }
                                          },
                                          "description":
                                          "GGI Canteen Order",
                                          "item_list": {
                                            "items": cart.items
                                                .values
                                                .map((item) => {
                                              "name": item
                                                  .foodItem
                                                  .name,
                                              "quantity":
                                              item.quantity,
                                              "price": item
                                                  .foodItem
                                                  .price
                                                  .toStringAsFixed(
                                                  2),
                                              "currency": "USD"
                                            })
                                                .toList()
                                          }
                                        }
                                      ],
                                      note:
                                      "Contact us for any questions on your order.",
                                      onSuccess:
                                          (Map params) async {
                                        cart.clear();
                                        ScaffoldMessenger.of(
                                            context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Payment Successful! Order Placed.'),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                      onError: (error) {
                                        ScaffoldMessenger.of(
                                            context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Payment Failed: $error'),
                                          ),
                                        );
                                      },
                                      onCancel: (params) {
                                        debugPrint(
                                            'Payment cancelled');
                                      },
                                    ),
                              ),
                            );
                          } else {
                            /// ❌ WINDOWS / DESKTOP SAFE MESSAGE
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'PayPal is supported only on Android & iOS',
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
                        ),
                        child: const Text(
                          'Checkout with PayPal',
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
