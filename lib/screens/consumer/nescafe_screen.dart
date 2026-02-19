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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final List<FoodItem> nescafeItems = [
      FoodItem(id: 'n1', name: 'Nescafe Cappuccino', category: 'Nescafe', description: 'Rich and creamy Italian cappuccino', price: 20, imageUrl: 'https://images.unsplash.com/photo-1534778101976-62847782c213?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'n2', name: 'Hot Chocolate', category: 'Nescafe', description: 'Indulgent melted luxury chocolate', price: 20, imageUrl: 'https://images.unsplash.com/photo-1544787210-2213d84ad960?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'n3', name: 'Nestea Cardamom', category: 'Nescafe', description: 'Fragrant cardamom infused tea', price: 10, imageUrl: 'https://images.unsplash.com/photo-1561336313-0bd5e0b27ec8?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'n4', name: 'Premium Cold Coffee', category: 'Nescafe', description: 'Chilled artisanal coffee delight', price: 40, imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'n10', name: 'Gourmet Pasta', category: 'Nescafe', description: 'Exquisite Italian sauced pasta', price: 40, imageUrl: 'https://images.unsplash.com/photo-1645112481338-3562e999f5fa?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'n11', name: 'Masala Maggie', category: 'Nescafe', description: 'Traditional spiced masala noodles', price: 30, imageUrl: 'https://images.unsplash.com/photo-1626807893526-285dc342df88?q=80&w=1974&auto=format&fit=crop'),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          final nescafeCount = cart.items.values.where((item) => item.foodItem.category == 'Nescafe').length;
          if (nescafeCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: primaryColor,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen(outletName: 'Nescafe'))),
            icon: Icon(Icons.shopping_basket_rounded, color: theme.brightness == Brightness.dark ? Colors.black : Colors.white),
            label: Text('Nescafe Cart (\$nescafeCount)', style: GoogleFonts.poppins(color: theme.brightness == Brightness.dark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
          );
        },
      ),
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true, expandedHeight: 250, backgroundColor: theme.appBarTheme.backgroundColor, iconTheme: theme.appBarTheme.iconTheme,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text('NESCAFE HUB', style: GoogleFonts.monoton(color: primaryColor, fontSize: 18, letterSpacing: 2)),
                background: Stack(fit: StackFit.expand, children: [
                  CachedNetworkImage(imageUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1974&auto=format&fit=crop", fit: BoxFit.cover),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.scaffoldBackgroundColor.withValues(alpha: 0.7), Colors.transparent, theme.scaffoldBackgroundColor], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, mainAxisSpacing: 16, crossAxisSpacing: 16),
                delegate: SliverChildBuilderDelegate((context, index) => ProductCard(foodItem: nescafeItems[index]), childCount: nescafeItems.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
