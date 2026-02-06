import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ggi_canteen/models/food_item.dart';
import 'package:ggi_canteen/widgets/product_card.dart';

class FruitCornerScreen extends StatefulWidget {
  const FruitCornerScreen({super.key});

  @override
  State<FruitCornerScreen> createState() => _FruitCornerScreenState();
}

class _FruitCornerScreenState extends State<FruitCornerScreen> with SingleTickerProviderStateMixin {
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
    final List<FoodItem> fruitItems = [
      FoodItem(id: 'f1', name: 'Apple', category: 'Fruit Corner', description: 'Fresh red apple', price: 20, imageUrl: 'https://images.unsplash.com/photo-1579613832125-5d34a1325c64?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'f2', name: 'Banana', category: 'Fruit Corner', description: 'Healthy ripe banana', price: 10, imageUrl: 'https://images.unsplash.com/photo-1528825871115-3581a5387919?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'f3', name: 'Orange', category: 'Fruit Corner', description: 'Juicy orange', price: 15, imageUrl: 'https://images.unsplash.com/photo-1580052614034-c55d20b62457?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'f4', name: 'Grapes', category: 'Fruit Corner', description: 'Fresh green grapes', price: 25, imageUrl: 'https://images.unsplash.com/photo-1596399770535-b21a2a4435de?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'f5', name: 'Watermelon', category: 'Fruit Corner', description: 'Cool watermelon slices', price: 30, imageUrl: 'https://images.unsplash.com/photo-1563884072132-49504df5b9af?q=80&w=1964&auto=format&fit=crop'),
      FoodItem(id: 'f6', name: 'Pineapple', category: 'Fruit Corner', description: 'Sweet pineapple', price: 35, imageUrl: 'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?q=80&w=1974&auto=format&fit=crop'),
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
                  'Fresh Fruit Corner',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: "https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=2070&auto=format&fit=crop",
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
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ProductCard(foodItem: fruitItems[index]);
                  },
                  childCount: fruitItems.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
