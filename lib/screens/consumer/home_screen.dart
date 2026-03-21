import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../services/auth_service.dart';
import '../auth/operator_user.dart';
import '../../models/food_item.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart'; 
import 'product_list_screen.dart';
import 'canteen_screen.dart';
import 'lipton_screen.dart';
import 'fruitcorner_screen.dart';
import 'nescafe_screen.dart';
import 'live_track_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
    
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    _logoController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _logoScale = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeInOutSine));
    _logoRotate = Tween<double>(begin: -0.02, end: 0.02).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeInOutSine));
    _glowAnimation = Tween<double>(begin: 5.0, end: 20.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeInOutSine));
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
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(category: category, products: filteredProducts)));
    }
  }

  void _refreshHomeScreen() {
    _fadeController.reset();
    _fadeController.forward();
    setState(() => _selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _buildDrawer(context, theme),
      extendBody: true, 
      bottomNavigationBar: _buildAnimatedBottomNavBar(theme),
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true, stretch: true, expandedHeight: 350, backgroundColor: theme.appBarTheme.backgroundColor,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: theme.colorScheme.surface.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: theme.primaryColor.withOpacity(0.3))),
                  child: Icon(Icons.menu, color: theme.primaryColor, size: 24),
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground, StretchMode.fadeTitle],
                centerTitle: true,
                title: AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                      ),
                      child: Text('GLOBAL EATS', style: GoogleFonts.monoton(color: theme.primaryColor, fontSize: 18, letterSpacing: 2, shadows: [Shadow(color: theme.primaryColor.withOpacity(0.6), blurRadius: _glowAnimation.value)])),
                    );
                  },
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/global_image.jpeg', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900], child: Icon(Icons.broken_image, color: theme.primaryColor, size: 50))),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            // 🌟 Optimized for Light Mode clarity (reduced from 0.8 to 0.15)
                            theme.scaffoldBackgroundColor.withOpacity(0.15), 
                            Colors.transparent, 
                            theme.scaffoldBackgroundColor.withOpacity(0.3), 
                            theme.scaffoldBackgroundColor
                          ], 
                          stops: const [0.0, 0.4, 0.7, 1.0], 
                          begin: Alignment.topCenter, 
                          end: Alignment.bottomCenter
                        )
                      )
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('Hungry? ', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w300, color: theme.colorScheme.onSurface)),
                      const Text('😋', style: TextStyle(fontSize: 28)),
                    ]),
                    Text('Global Eats Excellence', style: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.bold, color: theme.primaryColor, height: 1.1)),
                    const SizedBox(height: 40),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Explore Categories', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                      Container(width: 40, height: 2, color: theme.primaryColor)
                    ]),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 24, crossAxisSpacing: 24, childAspectRatio: 0.85),
                delegate: SliverChildListDelegate([
                  _buildEnhancedCategoryCard(theme, 'Nescafe', Icons.coffee_rounded, "assets/images/nescaffe.jpeg"),
                  _buildEnhancedCategoryCard(theme, 'Lipton', Icons.emoji_food_beverage_rounded, "assets/images/lipton_image.jpeg"),
                  _buildEnhancedCategoryCard(theme, 'Canteen', Icons.restaurant_rounded, "assets/images/canteen.jpeg"),
                  _buildEnhancedCategoryCard(theme, 'Fruit Corner', Icons.apple_rounded, "assets/images/fruit_corner.jpeg"),
                ]),
              ),
            ),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBottomNavBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 80,
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(35)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8), 
              borderRadius: BorderRadius.circular(35), 
              border: Border.all(color: theme.primaryColor.withOpacity(0.6), width: 1.5)
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _buildNavItem(theme, 0, Icons.home_rounded, "Home"),
              _buildNavItem(theme, 1, Icons.local_offer_rounded, "Offers"),
              _buildNavItem(theme, 2, Icons.local_shipping_rounded, "Live Track"),
              _buildNavItem(theme, 3, Icons.person_rounded, "Profile"),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(ThemeData theme, int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    Color unselectedColor = theme.colorScheme.onSurface.withOpacity(0.5);

    return GestureDetector(
      onTap: () {
        if (label == "Home") {
          _refreshHomeScreen();
        } else {
          setState(() => _selectedIndex = index);
          if (label == "Profile") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          } else if (label == "Live Track") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveTrackScreen()));
          }
        }
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent, shape: BoxShape.circle),
          child: Icon(icon, color: isSelected ? theme.primaryColor : unselectedColor, size: 26),
        ),
        Text(label, style: GoogleFonts.poppins(color: isSelected ? theme.primaryColor : unselectedColor, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }

  Widget _buildEnhancedCategoryCard(ThemeData theme, String title, IconData icon, String imagePath) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) => Transform.scale(scale: value, child: Opacity(opacity: value, child: child)),
      child: GestureDetector(
        onTap: () => _openCategory(context, title),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(children: [
              imagePath.startsWith('assets') ? Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity) : CachedNetworkImage(imageUrl: imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent, 
                      theme.scaffoldBackgroundColor.withOpacity(theme.brightness == Brightness.light ? 0.4 : 0.9)
                    ], 
                    begin: Alignment.topCenter, 
                    end: Alignment.bottomCenter
                  )
                )
              ),
              Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: theme.colorScheme.surface.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: theme.primaryColor.withOpacity(0.5))), child: Icon(icon, color: theme.primaryColor, size: 32)),
                  const SizedBox(height: 12),
                  Text(title, style: GoogleFonts.poppins(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    final logoUrl = "https://cdn-icons-png.flaticon.com/512/3170/3170733.png";
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(children: [
        DrawerHeader(
          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, border: Border(bottom: BorderSide(color: theme.primaryColor, width: 0.5))),
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 70, height: 70, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.primaryColor, width: 1.5)), child: ClipOval(child: CachedNetworkImage(imageUrl: logoUrl, fit: BoxFit.cover))),
            const SizedBox(height: 10),
            Text("GLOBAL EATS", style: GoogleFonts.monoton(color: theme.primaryColor, fontSize: 18)),
          ])),
        ),
        _buildDrawerItem(context, Icons.coffee, "Nescafe Menu", () => _openCategory(context, "Nescafe")),
        _buildDrawerItem(context, Icons.local_cafe, "Lipton Corner", () => _openCategory(context, "Lipton")),
        _buildDrawerItem(context, Icons.restaurant, "Main Canteen", () => _openCategory(context, "Canteen")),
        _buildDrawerItem(context, Icons.apple, "Fruit Corner", () => _openCategory(context, "Fruit Corner")),
        const Divider(color: Colors.white12),
        _buildDrawerItem(context, Icons.history, "My Orders", () {}),
        _buildDrawerItem(context, Icons.person, "Profile", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
        _buildDrawerItem(context, Icons.settings, "Settings", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        const Spacer(),
        _buildDrawerItem(context, Icons.logout, "Logout", () async {
          await context.read<AuthService>().logout();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OperatorUserScreen()), (_) => false);
        }, color: Colors.redAccent),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: color ?? theme.primaryColor),
      title: Text(title, style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color, fontSize: 16)),
      onTap: onTap,
    );
  }
}
