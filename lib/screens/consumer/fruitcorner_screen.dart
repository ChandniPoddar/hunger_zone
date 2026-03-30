import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:ggi_canteen/models/food_item.dart';
import '../../widgets/product_card.dart';
import '../../providers/cart_provider.dart';
import 'package:ggi_canteen/utils/constants.dart';
import 'cart_screen.dart';

class FruitCornerScreen extends StatefulWidget {
  const FruitCornerScreen({super.key});

  @override
  State<FruitCornerScreen> createState() => _FruitCornerScreenState();
}

class _FruitCornerScreenState extends State<FruitCornerScreen> with SingleTickerProviderStateMixin {
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
      // NOTE: Our backend handles "fruit" param to point to FruitCornerItem
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/items/fruit'));
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
          final fruitCount = cart.items.values.where((item) => item.foodItem.category == 'Fruit Corner').length;
          if (fruitCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: primaryColor,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen(outletName: 'Fruit Corner'))),
            icon: Icon(Icons.shopping_basket_rounded, color: theme.brightness == Brightness.dark ? Colors.black : Colors.white),
            label: Text(
              'Fruit Cart ($fruitCount)',
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
              expandedHeight: 250,
              backgroundColor: theme.appBarTheme.backgroundColor,
              iconTheme: theme.appBarTheme.iconTheme,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'GLOBAL FRUIT BAR',
                  style: GoogleFonts.monoton(
                    color: primaryColor,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/fruit_corner.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: Icon(Icons.apple, color: primaryColor, size: 50),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
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
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              sliver: isLoading 
                ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                : dynamicItems.isEmpty
                    ? const SliverToBoxAdapter(child: Center(child: Text("No items available")))
                    : SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
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
