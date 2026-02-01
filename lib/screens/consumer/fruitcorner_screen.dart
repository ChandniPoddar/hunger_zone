import 'package:flutter/material.dart';
import 'package:ggi_canteen/models/food_item.dart';
import '../../widgets/product_card.dart';

class FruitCornerScreen extends StatelessWidget {
  const FruitCornerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FoodItem> fruitItems = [
      FoodItem(
        id: 'f1',
        name: 'Apple',
        category: 'Fruit Corner',
        description: 'Fresh red apple',
        price: 20,
        imageUrl: '',
      ),
      FoodItem(
        id: 'f2',
        name: 'Banana',
        category: 'Fruit Corner',
        description: 'Healthy ripe banana',
        price: 10,
        imageUrl: '',
      ),
      FoodItem(
        id: 'f3',
        name: 'Orange',
        category: 'Fruit Corner',
        description: 'Juicy orange',
        price: 15,
        imageUrl: '',
      ),
      FoodItem(
        id: 'f4',
        name: 'Grapes',
        category: 'Fruit Corner',
        description: 'Fresh green grapes',
        price: 25,
        imageUrl: '',
      ),
      FoodItem(
        id: 'f5',
        name: 'Watermelon',
        category: 'Fruit Corner',
        description: 'Cool watermelon slices',
        price: 30,
        imageUrl: '',
      ),
      FoodItem(
        id: 'f6',
        name: 'Pineapple',
        category: 'Fruit Corner',
        description: 'Sweet pineapple',
        price: 35,
        imageUrl: '',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruit Corner'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: fruitItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            return ProductCard(foodItem: fruitItems[index]);
          },
        ),
      ),
    );
  }
}
