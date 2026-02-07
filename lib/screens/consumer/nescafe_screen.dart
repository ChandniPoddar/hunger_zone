import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../widgets/product_card.dart';
import '../../providers/cart_provider.dart';
import 'cart_screen.dart';

class NescafeScreen extends StatefulWidget {
  const NescafeScreen({super.key});

  @override
  State<NescafeScreen> createState() => _NescafeScreenState();
}

class _NescafeScreenState extends State<NescafeScreen> with SingleTickerProviderStateMixin {
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
    final List<FoodItem> nescafeItems = [
      FoodItem(id: 'n1', name: 'Nescafe Classic', category: 'Nescafe', description: 'Strong classic coffee', price: 20, imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=1937&auto=format&fit=crop'),
      FoodItem(id: 'n2', name: 'Cold Coffee', category: 'Nescafe', description: 'Chilled cold coffee', price: 30, imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'n3', name: 'Cappuccino', category: 'Nescafe', description: 'Creamy cappuccino', price: 35, imageUrl: 'https://images.unsplash.com/photo-1534778101976-62847782c213?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'n4', name: 'Hot Latte', category: 'Nescafe', description: 'Smooth milk coffee', price: 40, imageUrl: 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?q=80&w=1935&auto=format&fit=crop'),
      FoodItem(id: 'n5', name: 'Choco Mocha', category: 'Nescafe', description: 'Coffee with chocolate', price: 45, imageUrl: 'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?q=80&w=1913&auto=format&fit=crop'),
      FoodItem(
        id: 'n6', 
        name: 'Chocolate Lava', 
        category: 'Nescafe', 
        description: 'Rich, melting chocolate cake with vanilla ice cream', 
        price: 60, 
        imageUrl: 'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?q=80&w=2070&auto=format&fit=crop'
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          final nescafeCount = cart.items.values.where((item) => item.foodItem.category == 'Nescafe').length;
          if (nescafeCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: const Color(0xFFFFD700),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen(outletName: 'Nescafe'))),
            icon: const Icon(Icons.shopping_basket_rounded, color: Colors.black),
            label: Text(
              'Nescafe Cart ($nescafeCount)',
              style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
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
                  'Nescafe Hub',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1974&auto=format&fit=crop",
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
                    return ProductCard(foodItem: nescafeItems[index]);
                  },
                  childCount: nescafeItems.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
