import 'package:flutter/foundation.dart';
import 'package:ggi_canteen/models/cart_item.dart';
import 'package:ggi_canteen/models/food_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
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
    if (!_items.containsKey(foodId)) {
      return;
    }
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

  void clear() {
    _items.clear();
    notifyListeners();
  }

  // 🌟 Public normalization helper to ensure consistency
  String getNormalizedOutlet(String category) {
    String cat = category.trim();
    if (cat == 'Nescafe' || cat == 'Nescafe Menu' || cat == 'Beverage') return 'Nescafe';
    if (cat == 'Lipton' || cat == 'Lipton Corner' || cat == 'Tea Corner') return 'Lipton';
    if (cat == 'Canteen' || cat == 'Main Canteen' || cat == 'Fast Food' || cat == 'Pizza' || cat == 'Rolls') return 'Canteen';
    if (cat == 'Fruit Corner' || cat == 'Fresh Corner') return 'Fruit Corner';
    return cat;
  }

  // 🌟 GUARANTEED ORDER PLACEMENT AND CART CLEANING
  Future<String?> placeOrder({String? specificOutlet}) async {
    final user = _auth.currentUser;
    if (user == null) return "User session expired. Please login again.";
    
    // 1. Identify which items to process and remove
    final List<String> keysToRemove = [];
    final List<CartItem> itemsToOrder = [];

    _items.forEach((key, cartItem) {
      String outlet = getNormalizedOutlet(cartItem.foodItem.category);
      if (specificOutlet == null || outlet == specificOutlet) {
        itemsToOrder.add(cartItem);
        keysToRemove.add(key);
      }
    });

    if (itemsToOrder.isEmpty) return "No items found for $specificOutlet in cart.";

    try {
      final Map<String, List<CartItem>> ordersByOutlet = {};
      for (var item in itemsToOrder) {
        String outlet = getNormalizedOutlet(item.foodItem.category);
        if (!ordersByOutlet.containsKey(outlet)) {
          ordersByOutlet[outlet] = [];
        }
        ordersByOutlet[outlet]!.add(item);
      }

      final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch}";
      final writeBatch = _db.batch();

      ordersByOutlet.forEach((outlet, itemsList) {
        final outletOrderRef = _db.collection('orders').doc();
        
        final orderData = {
          'orderId': orderId,
          'customerEmail': user.email,
          'customerId': user.uid,
          'outlet': outlet, 
          'items': itemsList.map((i) => {
            'name': i.foodItem.name,
            'quantity': i.quantity,
            'price': i.foodItem.price,
          }).toList(),
          'total': itemsList.fold(0.0, (sum, i) => sum + (i.foodItem.price * i.quantity)),
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
        };

        writeBatch.set(outletOrderRef, orderData);
      });

      // 2. Perform Database Write
      await writeBatch.commit();
      
      // 3. 🌟 ATOMIC LOCAL CLEAN: Remove processed items one by one
      for (var key in keysToRemove) {
        _items.remove(key);
      }
      
      // 4. Update UI
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint("Order Error: $e");
      return "Check connection. Data could not be saved.";
    }
  }
}

extension on CartItem {
  double get totalPrice => foodItem.price * quantity;
}
