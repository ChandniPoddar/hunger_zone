import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:ggi_canteen/models/food_item.dart';
import '../../widgets/product_card.dart';
import '../../providers/cart_provider.dart';
import 'cart_screen.dart';

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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final List<FoodItem> fruitItems = [
      FoodItem(id: 'fc1', name: 'Mosambi Juice', category: 'Fruit Corner', description: 'Freshly squeezed premium citrus', price: 50, imageUrl: 'https://images.unsplash.com/photo-1613478223719-2ab802602423?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'fc2', name: 'Mix Juice', category: 'Fruit Corner', description: 'Optimal gourmet fruit blend', price: 40, imageUrl: 'https://images.unsplash.com/photo-1622597467827-43b0ef3c9a22?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'fc4', name: 'Pomegranate Juice', category: 'Fruit Corner', description: 'Luxury antioxidant ruby juice', price: 120, imageUrl: 'https://images.unsplash.com/photo-1541324904594-66ca8563497b?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'fc6', name: 'Banana Shake', category: 'Fruit Corner', description: 'Creamy artisanal banana blend', price: 30, imageUrl: 'https://images.unsplash.com/photo-1528825871115-3581a5387919?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'fc7', name: 'Mango Shake', category: 'Fruit Corner', description: 'Velvety king of fruits shake', price: 30, imageUrl: 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?q=80&w=2070&auto=format&fit=crop'),
    ];

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
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
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
