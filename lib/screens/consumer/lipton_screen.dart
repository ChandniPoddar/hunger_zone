import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../widgets/product_card.dart';
import '../../providers/cart_provider.dart';
import 'package:ggi_canteen/utils/constants.dart';
import 'cart_screen.dart';

class LiptonScreen extends StatefulWidget {
  const LiptonScreen({super.key});

  @override
  State<LiptonScreen> createState() => _LiptonScreenState();
}

class _LiptonScreenState extends State<LiptonScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  List<FoodItem> dynamicItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/items/lipton'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            dynamicItems = data.map((item) => FoodItem.fromMap(item['_id'] ?? '', item)).toList();
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          final liptonCount = cart.items.values.where((item) => item.foodItem.category == 'Lipton').length;
          if (liptonCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: primaryColor,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen(outletName: 'Lipton'))),
            icon: Icon(Icons.emoji_food_beverage_rounded, color: theme.brightness == Brightness.dark ? Colors.black : Colors.white),
            label: Text(
              'Lipton Cart ($liptonCount)',
              style: GoogleFonts.poppins(color: theme.brightness == Brightness.dark ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
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
              backgroundColor: theme.appBarTheme.backgroundColor,
              iconTheme: theme.appBarTheme.iconTheme,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Lipton Corner',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: "https://images.unsplash.com/photo-1515696455671-046a7c98094b?q=80&w=2070&auto=format&fit=crop",
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            // 🌟 Optimized: Reduced fog opacity
                            theme.scaffoldBackgroundColor.withValues(alpha: 0.15),
                            Colors.transparent,
                            theme.scaffoldBackgroundColor
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
              padding: const EdgeInsets.all(16),
              sliver: isLoading 
                ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                : dynamicItems.isEmpty
                    ? const SliverToBoxAdapter(child: Center(child: Text("No items available")))
                    : SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ProductCard(foodItem: dynamicItems[index]);
                          },
                          childCount: dynamicItems.length,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
