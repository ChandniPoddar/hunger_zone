import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("SETTINGS", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader("Appearance"),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: theme.primaryColor,
              ),
              title: Text(
                "Dark Mode",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                themeProvider.isDarkMode ? "Enabled" : "Disabled",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
              ),
              trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                activeColor: theme.primaryColor,
                onChanged: (value) => themeProvider.toggleTheme(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader("Account"),
          const SizedBox(height: 16),
          _buildSimpleTile(Icons.notifications_none_rounded, "Notifications", theme),
          _buildSimpleTile(Icons.security_rounded, "Privacy & Security", theme),
          _buildSimpleTile(Icons.help_outline_rounded, "Help & Support", theme),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        color: const Color(0xFFD4AF37),
      ),
    );
  }

  Widget _buildSimpleTile(IconData icon, String title, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: theme.primaryColor),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        onTap: () {},
      ),
    );
  }
}
