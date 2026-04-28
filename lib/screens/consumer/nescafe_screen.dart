import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hunger_zone/models/food_item.dart';
import 'package:hunger_zone/utils/constants.dart';
import '../../providers/outlet_provider.dart';
import '../../widgets/outlet_view.dart';

class NescafeScreen extends StatefulWidget {
  const NescafeScreen({super.key});

  @override
  State<NescafeScreen> createState() => _NescafeScreenState();
}

class _NescafeScreenState extends State<NescafeScreen> {
  List<FoodItem> dynamicItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/items/nescafe'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            dynamicItems = data.map((item) => FoodItem.fromMap(item['_id'] ?? '', item)).toList();
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OutletProvider>(
      builder: (context, outletProvider, child) {
        bool isOpen = outletProvider.isOpen('Nescafe');
        return OutletView(
          title: 'Nescafe',
          items: dynamicItems,
          isLoading: isLoading,
          isOpen: isOpen,
        );
      },
    );
  }
}

