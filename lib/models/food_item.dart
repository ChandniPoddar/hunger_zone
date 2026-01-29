class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
  });

  // Mock data factory
  static List<FoodItem> getMockItems() {
    return [
      FoodItem(
        id: '1',
        name: 'Veg Burger',
        description: 'Crispy vegetable patty with fresh lettuce and sauces',
        price: 5.99,
        imageUrl: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500&q=80',
        category: 'Fast Food',
      ),
      FoodItem(
        id: '2',
        name: 'Cheese Pizza',
        description: 'Classic margherita pizza with extra cheese',
        price: 8.99,
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80',
        category: 'Pizza',
      ),
      FoodItem(
        id: '3',
        name: 'Chicken Wrap',
        description: 'Grilled chicken wrapped in soft tortilla',
        price: 6.50,
        imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500&q=80',
        category: 'Rolls',
      ),
       FoodItem(
        id: '4',
        name: 'Iced Coffee',
        description: 'Cold brewed coffee with milk/cream',
        price: 3.50,
        imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b5dd7359?w=500&q=80',
        category: 'Beverage',
      ),
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
    };
  }
}
