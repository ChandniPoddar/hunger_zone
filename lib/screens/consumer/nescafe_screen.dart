import 'package:flutter/material.dart';
import 'package:ggi_canteen/models/food_item.dart';
import '../../widgets/product_card.dart';

class NescafeScreen extends StatelessWidget {
  const NescafeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FoodItem> nescafeItems = [
      FoodItem(
        id: 'n1',
        name: 'Nescafe Classic',
        category: 'Nescafe',
        description: 'Strong classic coffee',
        price: 20,
        imageUrl: '',
      ),
      FoodItem(
        id: 'n2',
        name: 'Cold Coffee',
        category: 'Nescafe',
        description: 'Chilled cold coffee',
        price: 30,
        imageUrl: '',
      ),
      FoodItem(
        id: 'n3',
        name: 'Cappuccino',
        category: 'Nescafe',
        description: 'Creamy cappuccino',
        price: 35,
        imageUrl: '',
      ),
      FoodItem(
        id: 'n4',
        name: 'Latte',
        category: 'Nescafe',
        description: 'Smooth milk coffee',
        price: 40,
        imageUrl: '',
      ),
      FoodItem(
        id: 'n5',
        name: 'Mocha',
        category: 'Nescafe',
        description: 'Coffee with chocolate',
        price: 45,
        imageUrl: '',
      ),
      FoodItem(
        id: 'n6',
        name: 'Hot Chocolate',
        category: 'Nescafe',
        description: 'Rich hot chocolate',
        price: 40,
        imageUrl: '',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nescafé'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: nescafeItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            return ProductCard(foodItem: nescafeItems[index]);
          },
        ),
      ),
    );
  }
}
