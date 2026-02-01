import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  bool _isAdmin = false;
  late final List<FoodItem> _products;

  @override
  void initState() {
    super.initState();
    _products = FoodItem.getMockItems();
  }

  void _openCategory(BuildContext context, String category) {
    debugPrint('Opening category: $category');

    // 🔹 Dedicated category screens
    if (category == 'Lipton') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LiptonScreen()),
      );
      return;
    }

    if (category == 'Nescafe') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NescafeScreen()),
      );
      return;
    }

    if (category == 'Fruit Corner') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FruitCornerScreen()),
      );
      return;
    }

    if (category == 'Canteen') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CanteenScreen()),
      );
      return;
    }

    // 🔹 Fallback (generic product list)
    final filteredProducts = _products
        .where((item) => item.category.trim() == category)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          category: category,
          products: filteredProducts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.itemCount == 0) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart),
            label: Text('${cart.itemCount} Items'),
          );
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('GGI Canteen'),
              background: Image.asset(
                'assets/images/hero_food.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.orange,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.restaurant,
                    size: 80,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
            actions: [
              if (_isAdmin)
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboard(),
                      ),
                    );
                  },
                ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await context.read<AuthService>().logout();
                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                        (_) => false,
                  );
                },
              ),
            ],
          ),

          /// HEADER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hungry?',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order your favorite food now!',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// CATEGORY GRID
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              delegate: SliverChildListDelegate(
                [
                  CategoryCard(
                    title: 'Nescafe',
                    icon: Icons.coffee,
                    onTap: () => _openCategory(context, 'Nescafe'),
                  ),
                  CategoryCard(
                    title: 'Lipton',
                    icon: Icons.local_cafe,
                    onTap: () => _openCategory(context, 'Lipton'),
                  ),
                  CategoryCard(
                    title: 'Canteen',
                    icon: Icons.restaurant,
                    onTap: () => _openCategory(context, 'Canteen'),
                  ),
                  CategoryCard(
                    title: 'Fruit Corner',
                    icon: Icons.apple,
                    onTap: () => _openCategory(context, 'Fruit Corner'),
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.only(bottom: 80),
          ),
        ],
      ),
    );
  }
}
