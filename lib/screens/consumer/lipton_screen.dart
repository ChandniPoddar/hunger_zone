import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/food_item.dart';
import '../../widgets/product_card.dart';

class LiptonScreen extends StatefulWidget {
  const LiptonScreen({super.key});

  @override
  State<LiptonScreen> createState() => _LiptonScreenState();
}

class _LiptonScreenState extends State<LiptonScreen> with SingleTickerProviderStateMixin {
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
    final List<FoodItem> liptonItems = [
      FoodItem(id: 'l1', name: 'Ice Tea Lemon', category: 'Lipton', description: 'Refreshing lemon ice tea', price: 25, imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?q=80&w=1964&auto=format&fit=crop'),
      FoodItem(id: 'l2', name: 'Ice Tea Peach', category: 'Lipton', description: 'Peach flavored ice tea', price: 25, imageUrl: 'https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'l3', name: 'Green Tea', category: 'Lipton', description: 'Healthy green tea', price: 20, imageUrl: 'https://images.unsplash.com/photo-1627435601361-ec25f5b1d0e5?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'l4', name: 'Honey Green Tea', category: 'Lipton', description: 'Green tea with honey', price: 30, imageUrl: 'https://images.unsplash.com/photo-1597481499750-3e6b22637e12?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'l5', name: 'Lemon Green Tea', category: 'Lipton', description: 'Green tea with lemon', price: 30, imageUrl: 'https://images.unsplash.com/photo-1563823245319-d4460bc7bc04?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'l6', name: 'Ice Tea Mint', category: 'Lipton', description: 'Cool mint ice tea', price: 25, imageUrl: 'https://images.unsplash.com/photo-1499638673689-79a0b5115d87?q=80&w=1964&auto=format&fit=crop'),
      FoodItem(id: 'l7', name: 'Classic Black Tea', category: 'Lipton', description: 'Strong black tea', price: 15, imageUrl: 'https://images.unsplash.com/photo-1576091160550-2173bdd99630?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'l8', name: 'Masala Tea', category: 'Lipton', description: 'Classic masala tea', price: 15, imageUrl: 'https://images.unsplash.com/photo-1561336313-0bd5e0b27ec8?q=80&w=2070&auto=format&fit=crop'),
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
                  'Lipton Corner',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: "/images/hero",
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
                    return ProductCard(foodItem: liptonItems[index]);
                  },
                  childCount: liptonItems.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
