import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hunger_zone/utils/constants.dart';

import 'package:hunger_zone/models/cart_item.dart';
import 'package:hunger_zone/models/food_item.dart';

class CartProvider with ChangeNotifier {

  final Map<String, CartItem> _items = {};

  static final String baseUrl = AppConstants.baseUrl;

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;

    _items.forEach((key, cartItem) {
      total += cartItem.foodItem.price * cartItem.quantity;
    });

    return total;
  }

  void addItem(FoodItem foodItem) {

    if (_items.containsKey(foodItem.id)) {

      _items.update(
        foodItem.id,
            (existingCartItem) => CartItem(
          id: existingCartItem.id,
          foodItem: existingCartItem.foodItem,
          quantity: existingCartItem.quantity + 1,
        ),
      );

    } else {

      _items.putIfAbsent(
        foodItem.id,
            () => CartItem(
          id: DateTime.now().toString(),
          foodItem: foodItem,
          quantity: 1,
        ),
      );

    }

    notifyListeners();
  }

  void removeSingleItem(String foodId) {

    if (!_items.containsKey(foodId)) return;

    if (_items[foodId]!.quantity > 1) {

      _items.update(
        foodId,
            (existingCartItem) => CartItem(
          id: existingCartItem.id,
          foodItem: existingCartItem.foodItem,
          quantity: existingCartItem.quantity - 1,
        ),
      );

    } else {

      _items.remove(foodId);

    }

    notifyListeners();
  }

  void removeItem(String foodId) {

    _items.remove(foodId);

    notifyListeners();

  }

  // ✅ Used in cart_screen.dart
  void clearCart() {

    _items.clear();

    notifyListeners();

  }

  // (kept for backward compatibility if used elsewhere)
  void clear() {

    clearCart();

  }

  String getNormalizedOutlet(String category) {

    String cat = category.trim();

    if (cat.contains('Nescafe')) return 'Nescafe';
    if (cat.contains('Lipton')) return 'Lipton';
    if (cat.contains('Canteen')) return 'Canteen';
    if (cat.contains('Fruit')) return 'Fruit Corner';

    return cat;

  }

  Future<String?> placeOrder({
    required String customerPhone,
    String? specificOutlet,
  }) async {

    final List<String> keysToClear = [];
    final List<CartItem> itemsToOrder = [];

    _items.forEach((key, cartItem) {

      String normalized = getNormalizedOutlet(cartItem.foodItem.category);

      if (specificOutlet == null || normalized == specificOutlet) {

        itemsToOrder.add(cartItem);
        keysToClear.add(key);

      }

    });

    if (itemsToOrder.isEmpty) {
      return "No items in cart";
    }

    try {

      final String orderId = "ORD-${DateTime.now().millisecondsSinceEpoch}";

      final Map<String, List<CartItem>> grouped = {};

      for (var item in itemsToOrder) {

        String outlet = getNormalizedOutlet(item.foodItem.category);

        grouped.putIfAbsent(outlet, () => []).add(item);

      }

      for (var entry in grouped.entries) {

        final outlet = entry.key;
        final itemList = entry.value;

        final response = await http.post(
          Uri.parse("$baseUrl/createOrder"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "orderId": orderId,
            "userPhone": customerPhone,
            "outlet": outlet,
            "items": itemList.map((i) => {
              "name": i.foodItem.name,
              "price": i.foodItem.price,
              "quantity": i.quantity,
            }).toList(),
            "total": itemList.fold(
              0.0,
                  (sum, i) => sum + (i.foodItem.price * i.quantity),
            ),
            "status": "Pending",
            "createdAt": DateTime.now().toIso8601String(),
          }),
        );

        if (response.statusCode != 200) {

          return "Order failed";

        }

      }

      for (var key in keysToClear) {

        _items.remove(key);

      }

      notifyListeners();

      return null;

    } catch (e) {

      debugPrint("Order error: $e");

      return "Server connection failed";

    }

  }

}

extension on CartItem {

  double get totalPrice => foodItem.price * quantity;

}
