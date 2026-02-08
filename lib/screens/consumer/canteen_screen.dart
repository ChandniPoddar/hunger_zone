import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:ggi_canteen/models/food_item.dart';
import '../../widgets/product_card.dart';
import '../../providers/cart_provider.dart';
import 'cart_screen.dart';

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
    // 🌟 Full Luxury Menu Digitized from physical Canteen Rate List
    final List<FoodItem> canteenItems = [
      FoodItem(id: 'c1', name: 'Sandwich Plain', category: 'Canteen', description: 'Freshly sliced healthy vegetable sandwich', price: 20, imageUrl: 'assets/images/grill sandwich.jpeg'),
      FoodItem(id: 'c2', name: 'Sandwich Grilled', category: 'Canteen', description: 'Buttery toasted gourmet grilled sandwich', price: 30, imageUrl: 'assets/images/grill sandwich.jpeg'),
      FoodItem(id: 'c3', name: 'White Sauce Pasta', category: 'Canteen', description: 'Creamy Italian style white sauce pasta', price: 40, imageUrl: 'assets/images/pasta.jpeg'),
      FoodItem(id: 'c4', name: 'Noodles (Full)', category: 'Canteen', description: 'Stir-fried street style hakka noodles', price: 60, imageUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?q=80&w=1984&auto=format&fit=crop'),
      FoodItem(id: 'c5', name: 'Noodles (Half)', category: 'Canteen', description: 'Delicious stir-fried snack portion', price: 30, imageUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?q=80&w=1984&auto=format&fit=crop'),
      FoodItem(id: 'c6', name: 'Classic Samosa', category: 'Canteen', description: 'Crispy golden fried potato pastry', price: 10, imageUrl: 'assets/images/samosa.jpeg'),
      FoodItem(id: 'c7', name: 'Samosa with Chana', category: 'Canteen', description: 'Crushed samosa with spicy chickpea curry', price: 40, imageUrl: 'assets/images/chana samosa.jpeg'),
      FoodItem(id: 'c8', name: 'Veg Manchurian', category: 'Canteen', description: 'Spicy Indo-Chinese vegetable balls', price: 40, imageUrl: 'assets/images/manchurian.jpeg'),
      FoodItem(id: 'c9', name: 'Spring Rolls (5 Pcs)', category: 'Canteen', description: 'Crispy fried rolls with vegetable filling', price: 40, imageUrl: 'assets/images/springroll.jpeg'),
      FoodItem(id: 'c10', name: 'Bhatura Chana', category: 'Canteen', description: 'Fluffy fried bread with spicy curry', price: 40, imageUrl: 'assets/images/bhatura chana.jpeg'),
      FoodItem(id: 'c11', name: 'Kulcha Chana', category: 'Canteen', description: 'Soft bread with authentic chickpea masala', price: 40, imageUrl: 'assets/images/khameri.jpeg'),
      FoodItem(id: 'c12', name: 'Bread Pakora', category: 'Canteen', description: 'Deep fried savory stuffed bread snack', price: 33, imageUrl: 'assets/images/pakoda.jpeg'),
      FoodItem(id: 'c13', name: 'Premium Burger', category: 'Canteen', description: 'Juicy vegetable patty with fresh salad', price: 40, imageUrl: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?q=80&w=2072&auto=format&fit=crop'),
      FoodItem(id: 'c14', name: 'Veg Patties', category: 'Canteen', description: 'Flaky baked pastry with savory filling', price: 20, imageUrl: 'assets/images/patties.jpeg'),
      FoodItem(id: 'c15', name: 'Bread Omelette', category: 'Canteen', description: 'Classic spiced egg omelette with toast', price: 40, imageUrl: 'assets/images/omlette.jpeg'),
      FoodItem(id: 'c16', name: 'Classic Maggi', category: 'Canteen', description: 'Favorite 2-minute masala noodles', price: 30, imageUrl: 'assets/images/maggie.jpeg'),
      FoodItem(id: 'c17', name: 'Special Tea', category: 'Canteen', description: 'Hot and refreshing 150ml milk tea', price: 10, imageUrl: 'https://images.unsplash.com/photo-1561336313-0bd5e0b27ec8?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'c18', name: 'Strong Coffee', category: 'Canteen', description: 'Energizing hot coffee blend 150ml', price: 20, imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=1937&auto=format&fit=crop'),
      FoodItem(id: 'c19', name: 'Cold Coffee (350ml)', category: 'Canteen', description: 'Premium chilled coffee shake', price: 40, imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=1974&auto=format&fit=crop'),
      FoodItem(id: 'c20', name: 'Malai Masala Chai', category: 'Canteen', description: 'Luxury rich cream spiced tea', price: 50, imageUrl: 'https://images.unsplash.com/photo-1561336313-0bd5e0b27ec8?q=80&w=2070&auto=format&fit=crop'),
      FoodItem(id: 'c21', name: 'Gourmet Ice Cream', category: 'Canteen', description: 'Assorted flavors based on MRP', price: 35, imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?q=80&w=1974&auto=format&fit=crop'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          final canteenCount = cart.items.values.where((item) => item.foodItem.category == 'Canteen').length;
          if (canteenCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: const Color(0xFFFFD700),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen(outletName: 'Canteen'))),
            icon: const Icon(Icons.shopping_basket_rounded, color: Colors.black),
            label: Text(
              'Canteen Cart ($canteenCount)',
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
                  'GLOBAL CANTEEN',
                  style: GoogleFonts.monoton(
                    color: const Color(0xFFFFD700),
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/canteen.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.restaurant, color: Color(0xFFFFD700), size: 50),
                      ),
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
