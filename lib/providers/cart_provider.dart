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

  String? _currentVendorId;
  String? _currentVendorName;
  String? _currentOutletName;

  String? get currentVendorId => _currentVendorId;
  String? get currentVendorName => _currentVendorName;
  String? get currentOutletName => _currentOutletName;

  static String getNormalizedVendorId(String category) {
    final clean = category.toLowerCase().trim();
    if (clean.contains('nescafe')) return 'nescafe';
    if (clean.contains('lipton')) return 'lipton';
    if (clean.contains('fruit')) return 'fruit_corner';
    return 'canteen';
  }

  static String getNormalizedVendorName(String category) {
    final clean = category.toLowerCase().trim();
    if (clean.contains('nescafe')) return 'Nescafé';
    if (clean.contains('lipton')) return 'Lipton';
    if (clean.contains('fruit')) return 'Fruit Corner';
    return 'Main Canteen';
  }

  static String normalizeOutlet(String category) {
    final clean = category.toLowerCase().trim();
    if (clean.contains('nescafe')) return 'Nescafe';
    if (clean.contains('lipton')) return 'Lipton';
    if (clean.contains('fruit')) return 'Fruit Corner';
    return 'Canteen';
  }

  String getNormalizedOutlet(String category) => normalizeOutlet(category);

  /// Adds item to cart. Returns existing vendor name if there is a vendor conflict, otherwise null.
  String? addItem(FoodItem foodItem) {
    final itemVendorId = getNormalizedVendorId(foodItem.category);
    final itemVendorName = getNormalizedVendorName(foodItem.category);
    final itemOutlet = getNormalizedOutlet(foodItem.category);

    // Enforce ONE ORDER = ONE VENDOR
    if (_items.isNotEmpty && _currentVendorId != null && _currentVendorId != itemVendorId) {
      return _currentVendorName ?? _currentOutletName ?? 'another vendor';
    }

    _currentVendorId = itemVendorId;
    _currentVendorName = itemVendorName;
    _currentOutletName = itemOutlet;

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
    return null;
  }

  /// Clears cart and adds the item from the new vendor
  void clearCartAndAdd(FoodItem foodItem) {
    _items.clear();
    _currentVendorId = getNormalizedVendorId(foodItem.category);
    _currentVendorName = getNormalizedVendorName(foodItem.category);
    _currentOutletName = getNormalizedOutlet(foodItem.category);

    _items.putIfAbsent(
      foodItem.id,
      () => CartItem(
        id: DateTime.now().toString(),
        foodItem: foodItem,
        quantity: 1,
      ),
    );
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
      if (_items.isEmpty) {
        _currentVendorId = null;
        _currentVendorName = null;
        _currentOutletName = null;
      }
    }

    notifyListeners();
  }

  void removeItem(String foodId) {
    _items.remove(foodId);
    if (_items.isEmpty) {
      _currentVendorId = null;
      _currentVendorName = null;
      _currentOutletName = null;
    }
    notifyListeners();
  }

  // ✅ Used in cart_screen.dart
  void clearCart() {
    _items.clear();
    _currentVendorId = null;
    _currentVendorName = null;
    _currentOutletName = null;
    notifyListeners();
  }

  // (kept for backward compatibility if used elsewhere)
  void clear() {
    clearCart();
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
