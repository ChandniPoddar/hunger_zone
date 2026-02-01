import 'package:flutter/material.dart';
import 'package:ggi_canteen/models/food_item.dart';
import '../../widgets/product_card.dart';

class LiptonScreen extends StatelessWidget {
  const LiptonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Mock Lipton Products
    final List<FoodItem> liptonItems = [
      FoodItem(
        id: 'l1',
        name: 'Lipton Ice Tea Lemon',
        category: 'Lipton',
        description: 'Refreshing lemon ice tea',
        price: 25,
        imageUrl: '',
      ),
      FoodItem(
        id: 'l2',
        name: 'Lipton Ice Tea Peach',
        category: 'Lipton',
        description: 'Peach flavored ice tea',
        price: 25,
        imageUrl: '',
      ),
      FoodItem(
        id: 'l3',
        name: 'Lipton Green Tea',
        category: 'Lipton',
        description: 'Healthy green tea',
        price: 20,
        imageUrl: '',
      ),
      FoodItem(
        id: 'l4',
        name: 'Lipton Honey Green Tea',
        category: 'Lipton',
        description: 'Green tea with honey',
        price: 30,
        imageUrl: '',
      ),
      FoodItem(
        id: 'l5',
        name: 'Lipton Lemon Green Tea',
        category: 'Lipton',
        description: 'Green tea with lemon',
        price: 30,
        imageUrl: '',
      ),
      FoodItem(
        id: 'l6',
        name: 'Lipton Ice Tea Mint',
        category: 'Lipton',
        description: 'Cool mint ice tea',
        price: 25,
        imageUrl: '',
      ),
      FoodItem(
        id: 'l7',
        name: 'Lipton Black Tea',
        category: 'Lipton',
        description: 'Strong black tea',
        price: 15,
        imageUrl: '',
      ),
      FoodItem(
        id: 'l8',
        name: 'Lipton Masala Tea',
        category: 'Lipton',
        description: 'Classic masala tea',
        price: 15,
        imageUrl: '',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lipton'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: liptonItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            return ProductCard(
              foodItem: liptonItems[index],
            );
          },
        ),
      ),
    );
  }
}
