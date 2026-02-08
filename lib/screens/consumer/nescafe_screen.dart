import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:ggi_canteen/models/food_item.dart';
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
    // 🌟 Full Luxury Menu Digitized from physical Nescafe Menu Image
    final List<FoodItem> nescafeItems = [
      // HOT BEVERAGES
      FoodItem(id: 'n1', name: 'Nescafe Cappuccino', category: 'Nescafe', description: 'Rich and creamy Italian cappuccino', price: 20, imageUrl: 'https://images.unsplash.com/photo-1534778101976-62847782c213?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'n2', name: 'Hot Chocolate', category: 'Nescafe', description: 'Indulgent melted luxury chocolate', price: 20, imageUrl: 'https://images.unsplash.com/photo-1544787210-2213d84ad960?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'n3', name: 'Nestea Cardamom', category: 'Nescafe', description: 'Fragrant cardamom infused tea', price: 10, imageUrl: 'https://images.unsplash.com/photo-1561336313-0bd5e0b27ec8?q=80&w=2070&auto=format&fit=crop'),
      
      // COLD BEVERAGES
      FoodItem(id: 'n4', name: 'Premium Cold Coffee', category: 'Nescafe', description: 'Chilled artisanal coffee delight', price: 40, imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'n5', name: 'Chilled Cold Chocolate', category: 'Nescafe', description: 'Refreshing dark chocolate shake', price: 40, imageUrl: 'https://images.unsplash.com/photo-1578314675249-a6910'
          'f80cc4e?q=80&w=1913&auto=format&fit=crop'),
      FoodItem(id: 'n6', name: 'Iced Tea Lemon', category: 'Nescafe', description: 'Zesty and cooling lemon tea', price: 30, imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?q=80&w=1964&auto=format&fit=crop'),
      
      // SOUP
      FoodItem(id: 'n7', name: 'Manchow Soup', category: 'Nescafe', description: 'Spicy oriental crunch soup', price: 30, imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?q=80&w=2071&auto=format&fit=crop'),
      FoodItem(id: 'n8', name: 'Tomato Soup', category: 'Nescafe', description: 'Rich classic roasted tomato soup', price: 30, imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?q=80&w=2071&auto=format&fit=crop'),
      FoodItem(id: 'n9', name: 'Sweetcorn Soup', category: 'Nescafe', description: 'Creamy and sweet corn medley', price: 30, imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?q=80&w=2071&auto=format&fit=crop'),
      
      // EATABLES
      FoodItem(id: 'n10', name: 'Gourmet Pasta', category: 'Nescafe', description: 'Exquisite Italian sauced pasta', price: 40, imageUrl: 'https://images.unsplash.com/photo-1645112481338-3562e999f5fa?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'n11', name: 'Masala Maggie', category: 'Nescafe', description: 'Traditional spiced masala noodles', price: 30, imageUrl: 'https://images.unsplash.com/photo-1626807893526-285dc342df88?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'n12', name: 'Cuppa Noodles', category: 'Nescafe', description: 'Quick and tasty cup noodles', price: 25, imageUrl: 'https://images.unsplash.com/photo-1626807893526-285dc342df88?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'n13', name: 'Artisan Chocolates', category: 'Nescafe', description: 'Selection of fine confectionery', price: 15, imageUrl: 'https://images.unsplash.com/photo-1511381939415-e44015466834?q=80&w=2072&auto=format&fit=crop'),
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
              'Nescafe Hub Cart ($nescafeCount)',
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
              expandedHeight: 250,
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'NESCAFE HUB',
                  style: GoogleFonts.monoton(
                    color: const Color(0xFFFFD700),
                    fontSize: 18,
                    letterSpacing: 2,
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
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                            Colors.black
                          ],
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
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
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
