import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ggi_canteen/utils/constants.dart';
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

  Future<void> deleteItem(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Delete Item", style: GoogleFonts.poppins(color: Colors.white)),
        content: Text("Are you sure you want to delete this item?", style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "${widget.category} Items",
          style: GoogleFonts.poppins(color: const Color(0xFFFFD700)),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : items.isEmpty
              ? Center(
                  child: Text(
                    "No items found for this category.",
                    style: GoogleFonts.poppins(color: Colors.white70),
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
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white10),
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
                                      color: Colors.white10,
                                      child: const Center(
                                        child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 2),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.white10,
                                      child: const Icon(Icons.fastfood, color: Colors.white38, size: 40),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                        onPressed: () => deleteItem(item['_id']),
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(),
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "₹${item['price']?.toString() ?? '0'}",
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFFFD700),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
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
