import 'package:flutter/material.dart';
import '../../models/food_item.dart';
import '../../widgets/product_card.dart';

class ProductListScreen extends StatelessWidget {
  final String category;
  final List<FoodItem> products;

  const ProductListScreen({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(foodItem: products[index]);
        },
      ),
    );
  }
}
