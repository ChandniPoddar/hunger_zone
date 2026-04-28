import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:hunger_zone/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ManageItemsScreen extends StatefulWidget {
  final String category;
  
  const ManageItemsScreen({super.key, required this.category});

  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response = await http.get(Uri.parse("${AppConstants.baseUrl}/items/${widget.category}"));
      
      if (response.statusCode == 200) {
        setState(() {
          items = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching items: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleAvailability(String id, bool val) async {
    try {
      final response = await http.put(
        Uri.parse("${AppConstants.baseUrl}/item-availability/${widget.category}/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"isAvailable": val}),
      );
      if (response.statusCode == 200) {
        fetchItems();
      }
    } catch (e) {
      debugPrint("Error toggling availability: $e");
    }
  }

  Future<void> deleteItem(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Item", style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this item?", style: TextStyle(color: Color(0xFF6C757D))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF6C757D), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);
    try {
      final response = await http.delete(Uri.parse("${AppConstants.baseUrl}/item/${widget.category}/$id"));
      if (response.statusCode == 200) {
        fetchItems();
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error deleting item: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light Gray
      appBar: AppBar(
        title: Text(
          "${widget.category} Menu",
          style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
          : items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFFE9ECEF)),
                      SizedBox(height: 16),
                      Text("No items found", style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Please add items to this category.", style: TextStyle(color: Color(0xFF6C757D))),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      bool isAvailable = item['isAvailable'] ?? true;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: item['imageUrl'] ?? '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: const Color(0xFFF8F9FA),
                                      child: const Center(
                                        child: CircularProgressIndicator(color: Color(0xFFE9ECEF), strokeWidth: 2),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: const Color(0xFFF8F9FA),
                                      child: const Icon(Icons.fastfood_outlined, color: Color(0xFFCED4DA), size: 40),
                                    ),
                                  ),
                                  // Availability Badge
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                       decoration: BoxDecoration(
                                         color: isAvailable ? const Color(0xFF28A745) : const Color(0xFFDC3545),
                                         borderRadius: BorderRadius.circular(8),
                                         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                       ),
                                       child: Text(
                                         isAvailable ? "AVAILABLE" : "STOCK OUT",
                                         style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                       ),
                                    ),
                                  ),
                                  // Delete Button
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () => deleteItem(item['_id']),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                                        ),
                                        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6B6B), size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['name'] ?? 'Unknown Item',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF1A1A2E),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "₹${item['price']?.toString() ?? '0'}",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFFF6B6B),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        // Premium Switch
                                        SizedBox(
                                          height: 25,
                                          width: 45,
                                          child: FittedBox(
                                            fit: BoxFit.fill,
                                            child: Switch(
                                              value: isAvailable,
                                              onChanged: (val) => toggleAvailability(item['_id'], val),
                                              activeColor: const Color(0xFF28A745),
                                              activeTrackColor: const Color(0xFF28A745).withOpacity(0.3),
                                              inactiveThumbColor: Colors.white,
                                              inactiveTrackColor: Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
