import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ggi_canteen/models/food_item.dart';
import '../../widgets/product_card.dart';

class CanteenScreen extends StatefulWidget {
  const CanteenScreen({super.key});

  @override
  State<CanteenScreen> createState() => _CanteenScreenState();
}

class _CanteenScreenState extends State<CanteenScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<FoodItem> canteenItems = [
      FoodItem(id: '1', name: 'Veg Burger', category: 'Canteen', description: 'Classic veg burger with cheese', price: 40, imageUrl: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?q=80&w=2072&auto=format&fit=crop'),
      FoodItem(id: '2', name: 'Cheese Sandwich', category: 'Canteen', description: 'Grilled cheese sandwich', price: 35, imageUrl: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?q=80&w=2073&auto=format&fit=crop'),
      FoodItem(id: '3', name: 'French Fries', category: 'Canteen', description: 'Crispy golden fries', price: 30, imageUrl: 'https://images.unsplash.com/photo-1576107232684-c579208ea380?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: '4', name: 'Veg Momos', category: 'Canteen', description: 'Steamed vegetable momos', price: 50, imageUrl: 'https://images.unsplash.com/photo-1670101730248-43544ae43878?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: '5', name: 'Paneer Roll', category: 'Canteen', description: 'Spicy paneer kathi roll', price: 60, imageUrl: 'https://images.unsplash.com/photo-1615852559638-34c11370218b?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: '6', name: 'Veg Pizza', category: 'Canteen', description: 'Mini veg pizza with cheese', price: 80, imageUrl: 'https://images.unsplash.com/photo-1594007654729-407eedc4be65?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: '7', name: 'Cold Coffee', category: 'Canteen', description: 'Chilled cold coffee shake', price: 45, imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: '8', name: 'Masala Tea', category: 'Canteen', description: 'Hot masala tea', price: 10, imageUrl: 'https://images.unsplash.com/photo-1561336313-0bd5e0b27ec8?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: '9', name: 'Filter Coffee', category: 'Canteen', description: 'Hot filter coffee', price: 15, imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=1937&auto=format&fit=crop'),
      FoodItem(id: '10', name: 'Veg Puff', category: 'Canteen', description: 'Baked vegetable puff pastry', price: 20, imageUrl: 'https://images.unsplash.com/photo-1627662386124-70e04b4c71c4?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: '11', name: 'Samosa', category: 'Canteen', description: 'Crispy aloo samosa', price: 15, imageUrl: 'https://images.unsplash.com/photo-1601050690594-7b73e5e60b0f?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: '12', name: 'Maggi Noodles', category: 'Canteen', description: 'Classic maggi noodles', price: 30, imageUrl: 'https://images.unsplash.com/photo-1626807893526-285dc342df88?q=80&w=1974&auto=format&fit=crop'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'GGI Main Canteen',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1974&auto=format&fit=crop",
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.transparent, Colors.black.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ProductCard(foodItem: canteenItems[index]);
                  },
                  childCount: canteenItems.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
