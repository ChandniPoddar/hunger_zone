import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class ChangeAdminCredentialsScreen extends StatefulWidget {
  final String? initialOutlet;
  const ChangeAdminCredentialsScreen({super.key, this.initialOutlet});

  @override
  State<ChangeAdminCredentialsScreen> createState() => _ChangeAdminCredentialsScreenState();
}

class _ChangeAdminCredentialsScreenState extends State<ChangeAdminCredentialsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentEmailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  static const Color primaryCoral = Color(0xFFFF5252);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color neutralBg = Color(0xFFF8FAFC);
  static const Color mutedText = Color(0xFF64748B);
  static const Color emeraldGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    final currentEmail = auth.email;
    if (currentEmail != null && currentEmail.isNotEmpty) {
      _currentEmailController.text = currentEmail;
      _newEmailController.text = currentEmail;
    }
  }

  @override
  void dispose() {
    _currentEmailController.dispose();
    _currentPasswordController.dispose();
    _newEmailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentEmail = _currentEmailController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();
    final newEmail = _newEmailController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    final auth = context.read<AuthService>();

    final error = await auth.changeAdminCredentials(
      currentEmail: currentEmail,
      currentPassword: currentPassword,
      newEmail: newEmail,
      newPassword: newPassword.isNotEmpty ? newPassword : null,
    );

    if (!mounted) return;

    if (error != null) {
      Fluttertoast.showToast(
        msg: error,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    } else {
      _showSuccessDialog(newEmail);
    }
  }

  void _showSuccessDialog(String updatedEmail) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: emeraldGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded, color: emeraldGreen, size: 42),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Credentials Updated!",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your admin credentials have been successfully updated to $updatedEmail. You can now use these details to log in anytime.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: mutedText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "DONE",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final outlet = auth.outletName ?? widget.initialOutlet ?? 'Canteen Outlet';

    return Scaffold(
      backgroundColor: neutralBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Admin Account Settings",
          style: GoogleFonts.poppins(
            color: darkNavy,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Outlet Info Banner Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [darkNavy, Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: darkNavy.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryCoral.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.storefront_rounded, color: primaryCoral, size: 26),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$outlet Partner",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Set your custom login credentials",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Current Credentials Section
                _buildSectionHeader("Current Credentials", Icons.security_rounded),
                const SizedBox(height: 12),
                _buildCard([
                  _buildLabel("Current Admin Email"),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _currentEmailController,
                    hint: "e.g. admin.nescafe@hungerzone.com",
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return "Current email is required";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Current Password"),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _currentPasswordController,
                    hint: "Enter existing password",
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscureCurrentPassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: mutedText,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return "Current password is required";
                      return null;
                    },
                  ),
                ]),

                const SizedBox(height: 24),

                // New Credentials Section
                _buildSectionHeader("New Credentials", Icons.vpn_key_rounded),
                const SizedBox(height: 12),
                _buildCard([
                  _buildLabel("New Admin Email"),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _newEmailController,
                    hint: "Enter your personal or business email",
                    icon: Icons.mark_email_read_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return "New email is required";
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(val.trim())) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("New Password"),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _newPasswordController,
                    hint: "Minimum 6 characters",
                    icon: Icons.lock_reset_rounded,
                    obscure: _obscureNewPassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: mutedText,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                    ),
                    validator: (val) {
                      if (val != null && val.isNotEmpty && val.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Confirm New Password"),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: "Re-type new password",
                    icon: Icons.check_circle_outline_rounded,
                    obscure: _obscureConfirmPassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: mutedText,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (val) {
                      if (_newPasswordController.text.isNotEmpty && val != _newPasswordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ]),

                const SizedBox(height: 20),

                // Note info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryCoral.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: primaryCoral.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: primaryCoral, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "After saving, you must use your new email and password for future logins. These changes will sync with the database.",
                          style: GoogleFonts.poppins(
                            color: darkNavy.withValues(alpha: 0.85),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Save Button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: darkNavy,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: darkNavy.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: auth.loading ? null : _handleSubmit,
                    child: auth.loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                "SAVE CREDENTIALS",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryCoral, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: darkNavy,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkNavy.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: darkNavy,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(
        color: darkNavy,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: neutralBg,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: mutedText.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: darkNavy, size: 20),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryCoral, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }
}
