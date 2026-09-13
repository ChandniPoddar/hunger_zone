import 'package:flutter_test/flutter_test.dart';
import 'package:hunger_zone/providers/cart_provider.dart';
import 'package:hunger_zone/models/food_item.dart';

void main() {
  group('CartProvider Single-Vendor Enforcement E2E Unit Tests', () {
    late CartProvider cart;

    final canteenBurger = FoodItem(
      id: 'c1',
      name: 'Veg Burger',
      description: 'Crispy patty',
      price: 50.0,
      imageUrl: 'https://example.com/burger.png',
      category: 'canteen',
    );

    final canteenSamosa = FoodItem(
      id: 'c2',
      name: 'Samosa',
      description: 'Hot samosa',
      price: 15.0,
      imageUrl: 'https://example.com/samosa.png',
      category: 'canteen',
    );

    final nescafeCoffee = FoodItem(
      id: 'n1',
      name: 'Cold Coffee',
      description: 'Chilled brew',
      price: 40.0,
      imageUrl: 'https://example.com/coffee.png',
      category: 'nescafe',
    );

    final liptonTea = FoodItem(
      id: 'l1',
      name: 'Green Tea',
      description: 'Herbal tea',
      price: 25.0,
      imageUrl: 'https://example.com/tea.png',
      category: 'lipton',
    );

    setUp(() {
      cart = CartProvider();
    });

    test('Initial cart is completely empty with null vendor', () {
      expect(cart.itemCount, 0);
      expect(cart.totalAmount, 0.0);
      expect(cart.currentVendorId, isNull);
      expect(cart.currentVendorName, isNull);
    });

    test('Adding first item locks cart to that vendor', () {
      final conflict = cart.addItem(canteenBurger);
      expect(conflict, isNull);
      expect(cart.itemCount, 1);
      expect(cart.currentVendorId, 'canteen');
      expect(cart.currentVendorName, 'Main Canteen');
      expect(cart.totalAmount, 50.0);
    });

    test('Adding second item from same vendor succeeds', () {
      cart.addItem(canteenBurger);
      final conflict = cart.addItem(canteenSamosa);
      expect(conflict, isNull);
      expect(cart.itemCount, 2);
      expect(cart.totalAmount, 65.0);
      expect(cart.currentVendorId, 'canteen');
    });

    test('Adding item from different vendor triggers conflict rejection', () {
      cart.addItem(canteenBurger);
      // Attempt to add Nescafe item to Canteen cart
      final conflict = cart.addItem(nescafeCoffee);
      expect(conflict, isNotNull);
      expect(conflict, 'Main Canteen');
      // Verify Nescafe item was NOT added
      expect(cart.itemCount, 1);
      expect(cart.totalAmount, 50.0);
      expect(cart.currentVendorId, 'canteen');
    });

    test('clearCartAndAdd switches vendor cleanly', () {
      cart.addItem(canteenBurger);
      expect(cart.currentVendorId, 'canteen');

      // Clear and switch to Lipton
      cart.clearCartAndAdd(liptonTea);
      expect(cart.itemCount, 1);
      expect(cart.currentVendorId, 'lipton');
      expect(cart.currentVendorName, 'Lipton');
      expect(cart.totalAmount, 25.0);
    });

    test('clearCart resets all items and vendor locks', () {
      cart.addItem(canteenBurger);
      cart.clearCart();
      expect(cart.itemCount, 0);
      expect(cart.totalAmount, 0.0);
      expect(cart.currentVendorId, isNull);
      expect(cart.currentVendorName, isNull);
    });
  });
}
