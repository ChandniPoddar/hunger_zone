import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunger_zone/models/food_item.dart';
import 'package:hunger_zone/providers/cart_provider.dart';
import 'package:hunger_zone/providers/wishlist_provider.dart';
import 'package:hunger_zone/utils/constants.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final FoodItem foodItem;

  const ProductCard({
    super.key,
    required this.foodItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Left side: Image
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: foodItem.imageUrl.isEmpty
                        ? _buildPlaceholder()
                        : foodItem.imageUrl.startsWith('assets')
                            ? Image.asset(
                                foodItem.imageUrl,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                              )
                            : CachedNetworkImage(
                                imageUrl: foodItem.imageUrl.startsWith('http') 
                                    ? foodItem.imageUrl 
                                    : "${AppConstants.baseUrl}${foodItem.imageUrl.startsWith('/') ? '' : '/'}${foodItem.imageUrl}",
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFF6B6B),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => _buildPlaceholder(),
                              ),
                  ),
                ),
                if (!foodItem.isAvailable)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC3545), size: 24),
                          const SizedBox(height: 4),
                          Text(
                            "UNAVAILABLE", 
                            style: GoogleFonts.poppins(color: const Color(0xFFDC3545), fontWeight: FontWeight.bold, fontSize: 8)
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlist, child) {
                      bool isFav = wishlist.isFavorite(foodItem.id);
                      return GestureDetector(
                        onTap: () => wishlist.toggleFavorite(foodItem),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border, 
                            size: 14, 
                            color: const Color(0xFFFF6B6B)
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Right side: Details
            Expanded(
              child: SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            foodItem.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF1A1A2E),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(foodItem.category).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            foodItem.category.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: _getCategoryColor(foodItem.category),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      foodItem.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6C757D),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${foodItem.price}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1A1A2E),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        InkWell(
                          onTap: foodItem.isAvailable ? () {
                            context.read<CartProvider>().addItem(foodItem);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFFFF6B6B),
                                content: Text(
                                  '${foodItem.name} added to cart',
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          } : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            decoration: BoxDecoration(
                              color: foodItem.isAvailable ? const Color(0xFFFF6B6B) : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              foodItem.isAvailable ? 'Add' : 'Sold Out', 
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
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
      ),
    );
  }

  Color _getCategoryColor(String category) {
    if (category.toLowerCase() == 'canteen') return const Color(0xFFFF6B6B);
    if (category.toLowerCase() == 'fruit corner') return const Color(0xFF4ECDC4);
    if (category.toLowerCase() == 'nescafe') return const Color(0xFF45B7D1);
    if (category.toLowerCase() == 'lipton') return const Color(0xFFF9CA24);
    return const Color(0xFFFF6B6B);
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: const Center(
        child: Text("🍔", style: TextStyle(fontSize: 32)),
      ),
    );
  }
}

