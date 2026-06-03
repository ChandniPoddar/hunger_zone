
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/outlet_provider.dart';




import '../../services/auth_service.dart';
import '../auth/operator_user.dart';
import '../profile/profile_screen.dart';

import 'canteen_screen.dart';
import 'lipton_screen.dart';
import 'fruitcorner_screen.dart';
import 'nescafe_screen.dart';
import 'live_track_screen.dart';

import 'wishlist_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _openCategory(BuildContext context, String category) {
    if (category == 'Lipton') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LiptonScreen()));
    } else if (category == 'Nescafe') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NescafeScreen()));
    } else if (category == 'Fruit Corner') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FruitCornerScreen()));
    } else if (category == 'Canteen') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CanteenScreen()));
    }
  }

  void _onNavItemTapped(int index) {
    if (index == 0) return; // Already on Home
    
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveTrackScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA), // Light Gray
      drawer: _buildDrawer(context),
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. APP BAR
              _buildAppBar(context),
              
              // 2. HERO SECTION
              _buildHeroSection(),
              
              // 3. QUICK CRAVINGS
              _buildQuickCravings(),

              // 4. CAMPUS HUBS
              _buildCampusHubs(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.segment_rounded, color: Color(0xFF1A1A2E), size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Column(
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on_rounded, color: Color(0xFFFF4B4B), size: 16),
                  SizedBox(width: 4),
                  Text("GGI CAMPUS", style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w900, fontSize: 16)),
                  Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1A1A2E), size: 20),
                ],
              ),
              const Text("Amritsar, Punjab", style: TextStyle(color: Color(0xFF6C757D), fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFF4B4B).withValues(alpha: 0.1),
              child: const Icon(Icons.person_rounded, color: Color(0xFFFF4B4B), size: 20),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: AssetImage("assets/images/global_image.jpeg"), // Used global_image.jpeg as requested collage
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.1),
                Colors.transparent,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "CAMPUS FAVORITES",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              const Text(
                "Fresh meals from Nescafe & Lipton",
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _openCategory(context, 'Nescafe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("ORDER NOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCravings() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Quick Cravings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E))),
              Text("See All", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFF4B4B))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildCravingItem(Icons.lunch_dining_rounded, "Burger"),
              _buildCravingItem(Icons.local_pizza_rounded, "Pizza"),
              _buildCravingItem(Icons.coffee_rounded, "Coffee"),
              _buildCravingItem(Icons.eco_rounded, "Healthy"),
              _buildCravingItem(Icons.cake_rounded, "Sweet"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCravingItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Center(
              child: Icon(icon, color: const Color(0xFFFF4B4B), size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }

  Widget _buildCampusHubs() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Campus Hubs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 16),
          _buildHubCard("Main Canteen", "North Indian • Fast Food", "4.2", "assets/images/canteen.jpeg", "Canteen"),
          const SizedBox(height: 16),
          _buildHubCard("Nescafe Hub", "Coffee • Snacks", "4.5", "assets/images/nescaffe.jpeg", "Nescafe"),
          const SizedBox(height: 16),
          _buildHubCard("Lipton Corner", "Tea • Bakery", "4.3", "assets/images/lipton_image.jpeg", "Lipton"),
          const SizedBox(height: 16),
          _buildHubCard("Fruit Corner", "Healthy • Juices", "4.8", "assets/images/fruit_corner.jpeg", "Fruit Corner"),
        ],
      ),
    );
  }

  Widget _buildHubCard(String title, String subtitle, String rating, String imagePath, String category) {
    return Consumer<OutletProvider>(
      builder: (context, outletProvider, child) {
        bool isOpen = outletProvider.isOpen(category);
        
        return GestureDetector(
          onTap: () => _openCategory(context, category),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (!isOpen)
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "CLOSED", 
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 4),
                          Text(subtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6C757D))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF28A745), // Green color matching screenshot
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(rating, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star_rounded, color: Colors.white, size: 13),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE9ECEF), width: 1)),
      ),
      child: NavigationBar(
        height: 65,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavItemTapped,
        indicatorColor: const Color(0xFFFF4B4B).withValues(alpha: 0.1),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_rounded, color: _selectedIndex == 0 ? const Color(0xFFFF4B4B) : const Color(0xFFADB5BD)),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_rounded, color: _selectedIndex == 1 ? const Color(0xFFFF4B4B) : const Color(0xFFADB5BD)),
            label: "Wishlist",
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_rounded, color: _selectedIndex == 2 ? const Color(0xFFFF4B4B) : const Color(0xFFADB5BD)),
            label: "Track",
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded, color: _selectedIndex == 3 ? const Color(0xFFFF4B4B) : const Color(0xFFADB5BD)),
            label: "History",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded, color: _selectedIndex == 4 ? const Color(0xFFFF4B4B) : const Color(0xFFADB5BD)),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    return Drawer(
      backgroundColor: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
              boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFFF4B4B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.restaurant_menu_rounded, color: Color(0xFFFF4B4B), size: 30),
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFFADB5BD))),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFFF4B4B).withValues(alpha: 0.1),
                      child: const Icon(Icons.person_rounded, color: Color(0xFFFF4B4B), size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?['name'] ?? "Welcome Guest",
                            style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?['phoneNumber'] ?? "Join the movement",
                            style: const TextStyle(color: Color(0xFF6C757D), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDrawerItem(Icons.home_outlined, Icons.home_rounded, "Campus Home", 0, () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 0);
                }),
                _buildDrawerItem(Icons.history_outlined, Icons.history_rounded, "My Orders", 3, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                }),
                _buildDrawerItem(Icons.favorite_outline_rounded, Icons.favorite_rounded, "My Wishlist", 1, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
                }),
                _buildDrawerItem(Icons.local_shipping_outlined, Icons.local_shipping_rounded, "Track Order", 2, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveTrackScreen()));
                }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                  child: Divider(color: Color(0xFFE9ECEF)),
                ),
                _buildDrawerItem(Icons.person_outline_rounded, Icons.person_rounded, "Profile Settings", 4, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                }),
                _buildDrawerItem(Icons.notifications_none_rounded, Icons.notifications_rounded, "Notifications", -1, () {}),
                _buildDrawerItem(Icons.help_outline_rounded, Icons.help_rounded, "Help & Support", -1, () {}),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                  child: Divider(color: Color(0xFFE9ECEF)),
                ),
                
                // Theme Toggle
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SwitchListTile(
                      activeThumbColor: const Color(0xFFFF4B4B),
                      secondary: Icon(
                        themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: themeProvider.isDarkMode ? const Color(0xFFFFD700) : const Color(0xFFFF4B4B),
                      ),
                      title: Text(
                        themeProvider.isDarkMode ? "Dark Mode" : "Light Mode",
                        style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF4B4B).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFFF4B4B)),
                title: const Text("Logout", style: TextStyle(color: Color(0xFFFF4B4B), fontWeight: FontWeight.bold)),
                onTap: () async {
                  await authService.logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OperatorUserScreen()), (_) => false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, IconData activeIcon, String title, int index, VoidCallback onTap) {
    bool isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFF4B4B).withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? const Color(0xFFFF4B4B) : const Color(0xFF495057),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFF4B4B) : const Color(0xFF1A1A2E),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: isSelected 
          ? Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFFFF4B4B), borderRadius: BorderRadius.circular(10)))
          : const Icon(Icons.chevron_right_rounded, color: Color(0xFFCED4DA), size: 18),
      ),
    );
  }
}
