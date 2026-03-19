import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../models/food_item.dart';

class AddEditProductScreen extends StatefulWidget {
  final FoodItem? foodItem;

  const AddEditProductScreen({super.key, this.foodItem});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  File? _imageFile;
  String _imageUrl = '';
  bool _isLoading = false;
  bool _isAvailable = true;

  /// CHANGE THIS TO YOUR NODE SERVER
  final String baseUrl = "http://10.0.2.2:5000/products";

  final List<String> _categories = [
    'Nescafe',
    'Lipton',
    'Canteen',
    'Fruit Corner',
    'Fast Food',
    'Pizza',
    'Rolls',
    'Beverage'
  ];

  @override
  void initState() {
    super.initState();

    if (widget.foodItem != null) {
      _nameController.text = widget.foodItem!.name;
      _descController.text = widget.foodItem!.description;
      _priceController.text = widget.foodItem!.price.toString();
      _categoryController.text = widget.foodItem!.category;
      _imageUrl = widget.foodItem!.imageUrl;
      _isAvailable = widget.foodItem!.isAvailable;
    } else {
      _categoryController.text = _categories[0];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _imageUrl;

      if (_imageFile != null) {
        /// TEMP IMAGE PLACEHOLDER
        finalImageUrl =
        "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=500&auto=format&fit=crop";
      }

      final productData = {
        "name": _nameController.text.trim(),
        "description": _descController.text.trim(),
        "price": double.parse(_priceController.text.trim()),
        "category": _categoryController.text.trim(),
        "imageUrl": finalImageUrl,
        "isAvailable": _isAvailable,
      };

      http.Response response;

      /// ADD PRODUCT
      if (widget.foodItem == null) {
        response = await http.post(
          Uri.parse(baseUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(productData),
        );
      }

      /// UPDATE PRODUCT
      else {
        response = await http.put(
          Uri.parse("$baseUrl/${widget.foodItem!.id}"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(productData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.foodItem == null
                    ? "Product Added"
                    : "Product Updated")),
          );

          Navigator.pop(context);
        }
      } else {
        throw Exception("Server Error: ${response.body}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.foodItem == null ? 'Add New Item' : 'Edit Item',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE PICKER
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : (_imageUrl.isNotEmpty
                        ? Image.network(_imageUrl, fit: BoxFit.cover)
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo,
                            size: 50, color: Color(0xFFFFD700)),
                        const SizedBox(height: 8),
                        Text("Add Product Photo",
                            style: GoogleFonts.poppins(
                                color: Colors.white54)),
                      ],
                    )),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              _buildLabel("Item Name"),
              _buildTextField(
                  _nameController, "e.g. Special Coffee", Icons.restaurant),

              const SizedBox(height: 20),

              /// CATEGORY
              _buildLabel("Category"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _categories.contains(_categoryController.text)
                        ? _categoryController.text
                        : _categories[0],
                    dropdownColor: const Color(0xFF1E1E1E),
                    isExpanded: true,
                    style: GoogleFonts.poppins(color: Colors.white),
                    items: _categories.map((String category) {
                      return DropdownMenuItem(
                          value: category, child: Text(category));
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _categoryController.text = val!),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// PRICE + STATUS
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Price (₹)"),
                        _buildTextField(_priceController, "0.00",
                            Icons.currency_rupee,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Status"),
                      Switch(
                        value: _isAvailable,
                        activeColor: const Color(0xFFFFD700),
                        onChanged: (val) => setState(() => _isAvailable = val),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildLabel("Description"),
              _buildTextField(
                  _descController, "What's in this dish?", Icons.description,
                  maxLines: 3),

              const SizedBox(height: 40),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _saveProduct,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                    widget.foodItem == null
                        ? 'ADD PRODUCT'
                        : 'UPDATE PRODUCT',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.w600,
            fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white24),
        prefixIcon: Icon(icon, color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFFFD700))),
      ),
      validator: (val) => val!.isEmpty ? 'This field is required' : null,
    );
  }
}
