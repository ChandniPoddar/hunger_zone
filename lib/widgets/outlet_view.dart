import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunger_zone/models/food_item.dart';
import 'package:hunger_zone/widgets/product_card.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/consumer/cart_screen.dart';

class OutletView extends StatefulWidget {
  final String title;
  final List<FoodItem> items;
  final bool isLoading;
  final bool isOpen;

  const OutletView({
    super.key,
    required this.title,
    required this.items,
    required this.isLoading,
    required this.isOpen,
  });

  @override
  State<OutletView> createState() => _OutletViewState();
}

class _OutletViewState extends State<OutletView> {
  String searchQuery = "";
  String selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();

  List<String> get categories => ["All", "Meals", "Beverages", "Snacks"];

  List<FoodItem> get filteredItems {
    return widget.items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(searchQuery.toLowerCase());
      
      if (selectedCategory == "All") return matchesSearch;
      
      // Basic categorization logic
      bool matchesCategory = false;
      if (selectedCategory == "Meals") {
        matchesCategory = item.name.toLowerCase().contains("thali") || 
                          item.name.toLowerCase().contains("bhature") ||
                          item.name.toLowerCase().contains("burger") ||
                          item.name.toLowerCase().contains("pizza");
      } else if (selectedCategory == "Beverages") {
        matchesCategory = item.name.toLowerCase().contains("tea") || 
                          item.name.toLowerCase().contains("coffee") ||
                          item.name.toLowerCase().contains("nescafe") ||
                          item.name.toLowerCase().contains("lipton") ||
                          item.name.toLowerCase().contains("shake") ||
                          item.name.toLowerCase().contains("juice");
      } else if (selectedCategory == "Snacks") {
        matchesCategory = item.name.toLowerCase().contains("maggi") || 
                          item.name.toLowerCase().contains("samosa") ||
                          item.name.toLowerCase().contains("patty") ||
                          item.name.toLowerCase().contains("roll");
      }
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF6B6B);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFB),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              final count = cart.items.values.where((item) => item.foodItem.category.toLowerCase() == widget.title.toLowerCase()).length;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Badge(
                    label: Text('$count'),
                    isLabelVisible: count > 0,
                    backgroundColor: primaryColor,
                    child: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CartScreen(outletName: widget.title)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search for ${widget.title} items...",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(
              children: categories.map((cat) {
                bool isSelected = selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade100,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : Colors.grey.shade500,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Items List
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
                : filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          "No items found",
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return ProductCard(foodItem: filteredItems[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

