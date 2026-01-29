// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ggi_canteen/models/food_item.dart';
import 'package:ggi_canteen/screens/admin/add_edit_product_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Builder(
        builder: (context) {
          final products = FoodItem.getMockItems();
          
          if (products.isEmpty) return const Center(child: Text('No products added yet.'));

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: product.imageUrl.isNotEmpty ? NetworkImage(product.imageUrl) : null,
                  child: product.imageUrl.isEmpty ? const Icon(Icons.fastfood) : null,
                ),
                title: Text(product.name),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit disabled in mock mode')));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete disabled in mock mode')));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

