import 'package:flutter/material.dart';
import 'package:ggi_canteen/models/food_item.dart';
import '../../widgets/product_card.dart';

class CanteenScreen extends StatelessWidget {
  const CanteenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Mock Canteen Products (12 items)
    final List<FoodItem> canteenItems = [
      FoodItem(
        id: '1',
        name: 'Veg Burger',
        category: 'Canteen',
        description: 'Fresh veg burger with cheese',
        price: 40,
        imageUrl: 'https://share.google/8T61KH0cmZ0gD7fsL',
      ),
      FoodItem(
        id: '2',
        name: 'Cheese Sandwich',
        category: 'Canteen',
        description: 'Grilled cheese sandwich',
        price: 35,
        imageUrl: 'https://share.google/aDIeQrNO15wPxnm3E',
      ),
      FoodItem(
        id: '3',
        name: 'French Fries',
        category: 'Canteen',
        description: 'Crispy french fries',
        price: 30,
        imageUrl: 'https://share.google/zVk9wvOv4rOg38d1q',
      ),
      FoodItem(
        id: '4',
        name: 'Veg Momos',
        category: 'Canteen',
        description: 'Steamed veg momos',
        price: 50,
        imageUrl: 'https://share.google/yG3iLZvBNwlywkcfA',
      ),
      FoodItem(
        id: '5',
        name: 'Paneer Roll',
        category: 'Canteen',
        description: 'Paneer wrap roll',
        price: 60,
        imageUrl: 'https://share.google/MHkCbSqbxUhvQnIky',
      ),
      FoodItem(
        id: '6',
        name: 'Veg Pizza',
        category: 'Canteen',
        description: 'Mini veg pizza',
        price: 80,
        imageUrl: 'https://share.google/MHkCbSqbxUhvQnIky',
      ),
      FoodItem(
        id: '7',
        name: 'Cold Coffee',
        category: 'Canteen',
        description: 'Chilled cold coffee',
        price: 45,
        imageUrl: 'https://i.imgur.com/QZyN5gS.png',
      ),
      FoodItem(
        id: '8',
        name: 'Tea',
        category: 'Canteen',
        description: 'Hot tea',
        price: 10,
        imageUrl: 'https://i.imgur.com/z2KJZtF.png',
      ),
      FoodItem(
        id: '9',
        name: 'Coffee',
        category: 'Canteen',
        description: 'Hot coffee',
        price: 15,
        imageUrl: 'https://i.imgur.com/5XkYzjL.png',
      ),
      FoodItem(
        id: '10',
        name: 'Veg Puff',
        category: 'Canteen',
        description: 'Baked veg puff',
        price: 20,
        imageUrl: 'https://i.imgur.com/vp9Jk3N.png',
      ),
      FoodItem(
        id: '11',
        name: 'Samosa',
        category: 'Canteen',
        description: 'Crispy samosa',
        price: 15,
        imageUrl: 'https://i.imgur.com/Z8yQxJf.png',
      ),
      FoodItem(
        id: '12',
        name: 'Maggi',
        category: 'Canteen',
        description: 'Hot maggi noodles',
        price: 30,
        imageUrl: 'https://i.imgur.com/8mVYt3h.png',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: canteenItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            return ProductCard(
              foodItem: canteenItems[index],
            );
          },
        ),
      ),
    );
  }
}
