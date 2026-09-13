import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hunger_zone/utils/constants.dart';

class VendorPaymentSettingsScreen extends StatefulWidget {
  final String? initialVendorId;
  const VendorPaymentSettingsScreen({super.key, this.initialVendorId});

  @override
  State<VendorPaymentSettingsScreen> createState() => _VendorPaymentSettingsScreenState();
}

class _VendorPaymentSettingsScreenState extends State<VendorPaymentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _merchantIdController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = true;
  bool _isSaving = false;

  List<dynamic> _vendors = [];
  String _selectedVendorId = 'canteen';

  static const Color primaryCoral = Color(0xFFFF5252);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color neutralBg = Color(0xFFF8FAFC);
  static const Color mutedText = Color(0xFF64748B);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    if (widget.initialVendorId != null && widget.initialVendorId!.isNotEmpty) {
      _selectedVendorId = widget.initialVendorId!.toLowerCase().replaceAll(' ', '_');
    }
    _fetchVendors();
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _receiverNameController.dispose();
    _merchantIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchVendors() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/api/vendors"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          setState(() {
            _vendors = data;
            // Verify selected vendor exists
            final exists = _vendors.any((v) => v['vendorId'] == _selectedVendorId);
            if (!exists) {
              _selectedVendorId = _vendors.first['vendorId'] ?? 'canteen';
            }
            _loadVendorIntoForm(_selectedVendorId);
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching vendors: $e");
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _loadVendorIntoForm(String vendorId) {
    final vendor = _vendors.firstWhere(
      (v) => v['vendorId'] == vendorId,
      orElse: () => null,
    );

    if (vendor != null) {
      _upiIdController.text = vendor['upiId'] ?? '';
      _receiverNameController.text = vendor['receiverName'] ?? '';
      _merchantIdController.text = vendor['merchantId'] ?? '5812';
      _isActive = vendor['isActive'] ?? true;
    } else {
      _upiIdController.clear();
      _receiverNameController.clear();
      _merchantIdController.text = '5812';
      _isActive = true;
    }
  }

  Map<String, dynamic>? get _currentVendor {
    try {
      return _vendors.firstWhere((v) => v['vendorId'] == _selectedVendorId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final upi = _upiIdController.text.trim();
    final receiver = _receiverNameController.text.trim();
    final merchant = _merchantIdController.text.trim();

    // Warn if one is filled but other is empty
    if ((upi.isNotEmpty && receiver.isEmpty) || (upi.isEmpty && receiver.isNotEmpty)) {
      Fluttertoast.showToast(
        msg: "Both UPI ID and Receiver Business Name are required to enable UPI payment",
        backgroundColor: warningOrange,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await http.put(
        Uri.parse("${AppConstants.baseUrl}/api/vendors/$_selectedVendorId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "upiId": upi,
          "receiverName": receiver,
          "merchantId": merchant.isNotEmpty ? merchant : '5812',
          "isActive": _isActive,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Fluttertoast.showToast(
          msg: "Vendor payment settings saved successfully!",
          backgroundColor: emeraldGreen,
          textColor: Colors.white,
        );

        // Update in memory list
        final updatedVendor = data['vendor'];
        setState(() {
          final index = _vendors.indexWhere((v) => v['vendorId'] == _selectedVendorId);
          if (index != -1) {
            _vendors[index] = updatedVendor;
          }
          _loadVendorIntoForm(_selectedVendorId);
        });

        _showSuccessDialog(updatedVendor);
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "Failed to save payment settings",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Connection error: $e",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> vendor) {
    final bool isConfigured = vendor['isPaymentConfigured'] == true;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isConfigured ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: isConfigured ? emeraldGreen : warningOrange,
            ),
            const SizedBox(width: 10),
            Text(
              "Settings Updated",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vendor: ${vendor['name'] ?? vendor['outletName']}",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: darkNavy),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isConfigured ? emeraldGreen.withValues(alpha: 0.12) : warningOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isConfigured
                    ? "STATUS: UPI ONLINE ACTIVE"
                    : "STATUS: CASH AT COUNTER ONLY",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isConfigured ? emeraldGreen : warningOrange,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isConfigured
                  ? "Direct UPI payments will now be credited to:\n${vendor['upiId']}\n(${vendor['receiverName']})"
                  : "Online UPI is disabled for this vendor. Customers can still order using 'Cash at Counter'.",
              style: GoogleFonts.poppins(fontSize: 13, color: mutedText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryCoral),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentVendor;
    final bool isConfigured = current != null && current['isPaymentConfigured'] == true;

    return Scaffold(
      backgroundColor: neutralBg,
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vendor Payment Setup",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "Multi-Vendor UPI Configuration",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: "Refresh Vendors",
            onPressed: _fetchVendors,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryCoral))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVendorSelector(),
                    const SizedBox(height: 20),
                    _buildStatusBanner(isConfigured, current),
                    const SizedBox(height: 24),
                    _buildFormCard(isConfigured),
                    const SizedBox(height: 24),
                    _buildArchitectureExplainer(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildVendorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SELECT OUTLET",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: mutedText,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _vendors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final v = _vendors[i];
              final isSelected = v['vendorId'] == _selectedVendorId;
              final isConfig = v['isPaymentConfigured'] == true;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedVendorId = v['vendorId'];
                    _loadVendorIntoForm(_selectedVendorId);
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? darkNavy : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? primaryCoral : Colors.black.withValues(alpha: 0.06),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? primaryCoral.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            color: isSelected ? Colors.white : darkNavy,
                            size: 20,
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isConfig ? emeraldGreen : warningOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v['name'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : darkNavy,
                            ),
                          ),
                          Text(
                            isConfig ? "UPI Active" : "COD Only",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isConfig ? emeraldGreen : warningOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner(bool isConfigured, Map<String, dynamic>? current) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConfigured ? emeraldGreen.withValues(alpha: 0.08) : warningOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConfigured ? emeraldGreen.withValues(alpha: 0.3) : warningOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isConfigured ? Icons.verified_user_rounded : Icons.warning_amber_rounded,
            color: isConfigured ? emeraldGreen : warningOrange,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConfigured ? "Online UPI Payments Active" : "Payment Currently Unavailable",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: darkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isConfigured
                      ? "Orders from ${current?['name']} directly trigger dynamic UPI intent to ${current?['receiverName']}."
                      : "UPI credentials are not configured for ${current?['name'] ?? 'this vendor'}. Customers will only see 'Cash at Counter'. Enter valid UPI ID & Payee Name below to activate UPI checkout.",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: mutedText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(bool isConfigured) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Payment Credentials",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
              if (_selectedVendorId == 'canteen')
                TextButton.icon(
                  icon: const Icon(Icons.restore_rounded, size: 16, color: primaryCoral),
                  label: Text(
                    "Fill Default",
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: primaryCoral),
                  ),
                  onPressed: () {
                    setState(() {
                      _upiIdController.text = "BHARATPE.9J0E0Z0U0M847077@unitype";
                      _receiverNameController.text = "SIMON RAJKUMAR GROVER";
                      _merchantIdController.text = "5812";
                      _isActive = true;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          // UPI ID
          _buildTextField(
            controller: _upiIdController,
            label: "UPI ID / VPA",
            hint: "e.g. BHARATPE.9J0E0Z0U0M847077@unitype",
            icon: Icons.qr_code_rounded,
            validator: (v) {
              if (v != null && v.trim().isNotEmpty && !v.contains('@')) {
                return "UPI ID must contain '@' (e.g. name@bank)";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Receiver Name
          _buildTextField(
            controller: _receiverNameController,
            label: "Receiver / Payee Business Name",
            hint: "e.g. SIMON RAJKUMAR GROVER",
            icon: Icons.business_rounded,
          ),
          const SizedBox(height: 16),

          // Merchant Category Code (MCC)
          _buildTextField(
            controller: _merchantIdController,
            label: "Merchant Code (MCC)",
            hint: "5812 (Restaurants & Fast Food)",
            icon: Icons.confirmation_number_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Active switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vendor Status",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: darkNavy,
                    ),
                  ),
                  Text(
                    _isActive ? "Vendor is open for orders" : "Vendor is currently closed",
                    style: GoogleFonts.poppins(fontSize: 12, color: mutedText),
                  ),
                ],
              ),
              Switch(
                value: _isActive,
                activeThumbColor: primaryCoral,
                onChanged: (val) => setState(() => _isActive = val),
              ),
            ],
          ),

          if (isConfigured) ...[
            const Divider(height: 30),
            TextButton.icon(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 18),
              label: Text(
                "Disable UPI Payment (Switch to COD Only)",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () {
                setState(() {
                  _upiIdController.clear();
                  _receiverNameController.clear();
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: darkNavy,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 14, color: darkNavy, fontWeight: FontWeight.w500),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: mutedText.withValues(alpha: 0.6)),
            prefixIcon: Icon(icon, color: mutedText, size: 20),
            filled: true,
            fillColor: neutralBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryCoral, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArchitectureExplainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_rounded, color: primaryCoral, size: 20),
              const SizedBox(width: 8),
              Text(
                "Dynamic Multi-Vendor Rules",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBulletItem("1 Order = 1 Vendor: Carts cannot mix items across different outlets."),
          _buildBulletItem("Secure Intent: Receiver UPI and totals are verified server-side on each order."),
          _buildBulletItem("Direct Settlement: UPI payments credit directly to the respective vendor's bank account."),
          _buildBulletItem("Graceful Fallback: When UPI is unconfigured, customers can seamlessly choose 'Cash at Counter'."),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: primaryCoral, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12, color: mutedText, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCoral,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: primaryCoral.withValues(alpha: 0.4),
        ),
        onPressed: _isSaving ? null : _saveSettings,
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Save & Update Credentials",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
