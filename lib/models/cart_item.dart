import 'package:ggi_canteen/models/food_item.dart';

class CartItem {
  final String id;
  final FoodItem foodItem;
  int quantity;

  CartItem({
    required this.id,
    required this.foodItem,
    this.quantity = 1,
  });

  double get totalPrice => foodItem.price * quantity;
}
