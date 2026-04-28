import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';

class WishlistProvider with ChangeNotifier {
  final List<FoodItem> _items = [];
  static const String _wishlistKey = 'user_wishlist';

  List<FoodItem> get items => [..._items];

  WishlistProvider() {
    _loadWishlist();
  }

  bool isFavorite(String id) {
    return _items.any((item) => item.id == id);
  }

  void toggleFavorite(FoodItem foodItem) {
    final index = _items.indexWhere((item) => item.id == foodItem.id);
    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.add(foodItem);
    }
    _saveWishlist();
    notifyListeners();
  }

  Future<void> _loadWishlist() async {
    // For now, keeping it in memory or simple storage
    // In a real app, this might come from the backend
    notifyListeners();
  }

  Future<void> _saveWishlist() async {
    // Persist if needed
  }
}
