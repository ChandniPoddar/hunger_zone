import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:hunger_zone/utils/constants.dart';
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AddItemScreen extends StatefulWidget {
  final String outlet;
  const AddItemScreen({super.key, required this.outlet});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Meals'; // Default sub-category
  bool _isLoading = false;
  File? _selectedImage;

  final List<String> _subCategories = ['Meals', 'Beverages', 'Snacks', 'Sweets'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitData() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _selectedImage == null) {
      Fluttertoast.showToast(msg: "Please fill all fields and pick an image");
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${AppConstants.baseUrl}/add-item"),
      );
      
      request.fields['name'] = _nameController.text;
      request.fields['price'] = _priceController.text;
      request.fields['description'] = _descController.text;
      request.fields['category'] = widget.outlet; // Fixed outlet
      request.fields['subCategory'] = _selectedCategory;
      
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Item Added Successfully!");
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: "Failed to add item");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Connection Error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF6B6B);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text(
          "Add New Menu Item", 
          style: GoogleFonts.poppins(color: const Color(0xFF1A1A2E), fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFBFBFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront, color: Color(0xFFFF6B6B), size: 18),
                      const SizedBox(width: 10),
                      Text(
                        "Outlet: ${widget.outlet}",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1A1A2E)),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(height: 1),
                  ),
                  _buildInput("Item Name", _nameController, Icons.fastfood_outlined),
                  const SizedBox(height: 16),
                  _buildInput("Price (₹)", _priceController, Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildInput("Description", _descController, Icons.description_outlined, maxLines: 2),
                  const SizedBox(height: 16),
                  
                  Text(
                    "Select Category",
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                        isExpanded: true,
                        items: _subCategories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(Icons.add_photo_alternate_outlined, size: 30, color: primaryColor),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Tap to Pick Detailed Image", 
                            style: GoogleFonts.poppins(color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontSize: 13)
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 35),

            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFFFF6B6B))
                : SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      onPressed: _submitData,
                      child: Text(
                        "SAVE ITEM", 
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(color: const Color(0xFF1A1A2E), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFFFF6B6B), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }
}

