import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../services/auth_service.dart';
import '../../providers/cart_provider.dart';
import '../../models/food_item.dart';

import '../admin/admin_dashboard.dart';
import '../auth/login_screen.dart';
import 'cart_screen.dart';
import '../../widgets/category_card.dart';

import 'product_list_screen.dart';
import 'canteen_screen.dart';
import 'lipton_screen.dart';
import 'fruitcorner_screen.dart';
import 'nescafe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final bool _isAdmin = false;
  late final List<FoodItem> _products;
  
  late AnimationController _fadeController;
  late Animation<double> _fade;
  
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;

  // URL for your dynamic logo
  final String logoUrl = "https://i.ibb.co/9G3t7fN/ggi-logo-placeholder.png";

  @override
  void initState() {
    super.initState();
    _products = FoodItem.getMockItems();
    
    // Page Fade Entrance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    // Logo Animation (Dashing & Creative)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOutSine),
    );
    
    _logoRotate = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _openCategory(BuildContext context, String category) {
    if (category == 'Lipton') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LiptonScreen()));
      return;
    }
    if (category == 'Nescafe') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NescafeScreen()));
      return;
    }
    if (category == 'Fruit Corner') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FruitCornerScreen()));
      return;
    }
    if (category == 'Canteen') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CanteenScreen()));
      return;
    }

    final filteredProducts = _products.where((item) => item.category.trim() == category).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListScreen(category: category, products: filteredProducts),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.itemCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: const Color(0xFFFFD700),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            label: Text(
              '${cart.itemCount} Items',
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
              expandedHeight: 280,
              backgroundColor: Colors.black,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Text(
                      'GGI CANTEEN',
                      style: GoogleFonts.monoton(
                        color: const Color(0xFFFFD700),
                        fontSize: 22,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            blurRadius: 10 * _logoScale.value,
                          )
                        ],
                      ),
                    );
                  },
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070&auto=format&fit=crop",
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.transparent, Colors.black.withOpacity(0.9)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Animated Logo Icon
                    Center(
                      child: AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _logoRotate.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    )
                                  ],
                                ),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: logoUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700))),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.restaurant_menu_rounded,
                                      size: 50,
                                      color: Color(0xFFFFD700),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (_isAdmin)
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings, color: Color(0xFFFFD700)),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard())),
                  ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFFFFD700)),
                  onPressed: () async {
                    await context.read<AuthService>().logout();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hungry? 😋',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order your favorite food now!',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Explore Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildListDelegate([
                  _buildCategoryCard('Nescafe', Icons.coffee_rounded, "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1974&auto=format&fit=crop"),
                  _buildCategoryCard('Lipton', Icons.emoji_food_beverage_rounded, "https://images.unsplash.com/photo-1544787210-2213d84ad960?q=80&w=1974&auto=format&fit=crop"),
                  _buildCategoryCard('Canteen', Icons.restaurant_rounded, "https://images.unsplash.com/photo-1567620905732-2d1ec7bb7445?q=80&w=1980&auto=format&fit=crop"),
                  _buildCategoryCard('Fruit Corner', Icons.apple_rounded, "https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=2070&auto=format&fit=crop"),
                ]),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, String imageUrl) {
    return GestureDetector(
      onTap: () => _openCategory(context, title),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: const Color(0xFFFFD700), size: 40),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
