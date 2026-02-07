import 'dart:ui';
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
import '../profile/profile_screen.dart';

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
  final bool _isAdmin = true; 
  late final List<FoodItem> _products;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  late AnimationController _fadeController;
  late Animation<double> _fade;
  
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _products = FoodItem.getMockItems();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOutSine),
    );
    
    _logoRotate = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOutSine),
    );

    _glowAnimation = Tween<double>(begin: 5.0, end: 20.0).animate(
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
    } else if (category == 'Nescafe') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NescafeScreen()));
    } else if (category == 'Fruit Corner') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FruitCornerScreen()));
    } else if (category == 'Canteen') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CanteenScreen()));
    } else {
      final filteredProducts = _products.where((item) => item.category.trim() == category).toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductListScreen(category: category, products: filteredProducts),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: _buildDrawer(context),
      extendBody: true, 
      bottomNavigationBar: _buildAnimatedBottomNavBar(),
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: 350,
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.menu, color: Color(0xFFFFD700), size: 24),
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                centerTitle: true,
                title: AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
                      ),
                      child: Text(
                        'GLOBAL EATS',
                        style: GoogleFonts.monoton(
                          color: const Color(0xFFFFD700),
                          fontSize: 18,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFFD700).withOpacity(0.6),
                              blurRadius: _glowAnimation.value,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/global_image.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.broken_image, color: Color(0xFFFFD700), size: 50),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                            Colors.black,
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (_isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Color(0xFFFFD700)),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard())),
                    ),
                  ),
              ],
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFFFFD700)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Search for your favorite food...",
                          style: GoogleFonts.poppins(color: Colors.white38),
                        ),
                      ),
                      const Icon(Icons.mic_none, color: Color(0xFFFFD700)),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hungry? ',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          '😋',
                          style: TextStyle(fontSize: 28),
                        ),
                      ],
                    ),
                    Text(
                      'Global Eats Excellence',
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Explore Categories',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 2,
                          color: const Color(0xFFFFD700),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _buildEnhancedCategoryCard('Nescafe', Icons.coffee_rounded, "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1974&auto=format&fit=crop"),
                  _buildEnhancedCategoryCard('Lipton', Icons.emoji_food_beverage_rounded, "assets/images/lipton.jpeg"),
                  _buildEnhancedCategoryCard('Canteen', Icons.restaurant_rounded, "assets/images/canteen.jpeg"),
                  _buildEnhancedCategoryCard('Fruit Corner', Icons.apple_rounded, "assets/images/fruit_corner.jpeg"),
                ]),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on, color: Colors.black, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "FLASH DEALS",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "ENDS IN: 00:14:59",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(35),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, "Home"),
                _buildNavItem(1, Icons.local_offer_rounded, "Offers"),
                const SizedBox(width: 60), 
                _buildNavItem(2, Icons.local_shipping_rounded, "Live Track"),
                _buildNavItem(3, Icons.person_rounded, "Profile"),
              ],
            ),
          ),
        ),
      ),
    ).withOrderButton(context);
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (label == "Profile") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFD700).withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFFFFD700) : Colors.white38,
              size: 26,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? const Color(0xFFFFD700) : Colors.white38,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCategoryCard(String title, IconData icon, String imagePath) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _openCategory(context, title),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                imagePath.startsWith('assets') 
                  ? Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                  : CachedNetworkImage(imageUrl: imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
                        ),
                        child: Icon(icon, color: const Color(0xFFFFD700), size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final logoUrl = "https://cdn-icons-png.flaticon.com/512/3170/3170733.png";
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 0.5)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    ),
                    child: ClipOval(child: CachedNetworkImage(imageUrl: logoUrl, fit: BoxFit.cover)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "GLOBAL EATS",
                    style: GoogleFonts.monoton(color: const Color(0xFFFFD700), fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(Icons.coffee, "Nescafe Menu", () {
            Navigator.pop(context);
            _openCategory(context, "Nescafe");
          }),
          _buildDrawerItem(Icons.local_cafe, "Lipton Corner", () {
            Navigator.pop(context);
            _openCategory(context, "Lipton");
          }),
          _buildDrawerItem(Icons.restaurant, "Main Canteen", () {
            Navigator.pop(context);
            _openCategory(context, "Canteen");
          }),
          _buildDrawerItem(Icons.apple, "Fruit Corner", () {
            Navigator.pop(context);
            _openCategory(context, "Fruit Corner");
          }),
          const Divider(color: Colors.white12),
          _buildDrawerItem(Icons.history, "My Orders", () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.person, "Profile", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }),
          _buildDrawerItem(Icons.settings, "Settings", () {
            Navigator.pop(context);
          }),
          const Spacer(),
          _buildDrawerItem(Icons.logout, "Logout", () async {
            await context.read<AuthService>().logout();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          }, color: Colors.redAccent),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color color = const Color(0xFFFFD700)}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}

extension on Widget {
  Widget withOrderButton(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        this,
        Positioned(
          bottom: 40,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
            },
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_menu_rounded, color: Colors.black, size: 30),
                  Text(
                    "Order",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
