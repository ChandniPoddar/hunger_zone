import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:hunger_zone/utils/constants.dart';
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Nescafe'; // Default
  bool _isLoading = false;
  File? _selectedImage;

  final List<String> _categories = ['Nescafe', 'Lipton', 'Canteen', 'Fruit Corner'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
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
      request.fields['category'] = _selectedCategory;
      
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Item Added Successfully!");
        Navigator.pop(context); // Go back after success
      } else {
        Fluttertoast.showToast(msg: "Failed to add item");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Connection Error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Add New Menu Item", style: GoogleFonts.poppins(color: const Color(0xFFFFD700))),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInput("Item Name", _nameController, Icons.fastfood),
            const SizedBox(height: 20),
            _buildInput("Price (₹)", _priceController, Icons.currency_rupee, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50, color: const Color(0xFFFFD700).withOpacity(0.7)),
                          const SizedBox(height: 10),
                          const Text("Tap to Pick Image", style: TextStyle(color: Colors.white70)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  isExpanded: true,
                  items: _categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            const SizedBox(height: 40),

            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _submitData,
              child: Text("SAVE ITEM", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}
