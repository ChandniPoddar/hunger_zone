import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/auth_service.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {

          const Color lightPrimary = Color(0xFF800020); // Royal Burgundy
          const Color darkPrimary = Color(0xFFD4AF37); // Champagne Gold

          return MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthService>(
                create: (_) => AuthService(),
              ),
              ChangeNotifierProvider<CartProvider>(
                create: (_) => CartProvider(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Global Eats',
              themeMode: themeProvider.themeMode,

              // -------- LIGHT THEME --------
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                primaryColor: lightPrimary,
                scaffoldBackgroundColor: const Color(0xFFFDFBF7),

                colorScheme: ColorScheme.light(
                  primary: lightPrimary,
                  secondary: const Color(0xFFB76E79),
                  surface: Colors.white,
                  onSurface: const Color(0xFF2C3E50),
                ),

                navigationBarTheme: NavigationBarThemeData(
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  indicatorColor: lightPrimary.withValues(alpha: 0.1),
                  labelTextStyle: WidgetStateProperty.all(
                    GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ),

                appBarTheme: AppBarTheme(
                  backgroundColor: const Color(0xFFFDFBF7),
                  elevation: 0,
                  centerTitle: true,
                  titleTextStyle: GoogleFonts.poppins(
                    color: lightPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  iconTheme: const IconThemeData(color: lightPrimary),
                ),
              ),

              // -------- DARK THEME --------
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                primaryColor: darkPrimary,
                scaffoldBackgroundColor: const Color(0xFF121212),

                colorScheme: const ColorScheme.dark(
                  primary: darkPrimary,
                  secondary: Color(0xFFE5C76B),
                  surface: Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                ),

                navigationBarTheme: NavigationBarThemeData(
                  backgroundColor:
                  const Color(0xFF1E1E1E).withValues(alpha: 0.8),
                  indicatorColor: darkPrimary.withValues(alpha: 0.1),
                  labelTextStyle: WidgetStateProperty.all(
                    GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),

                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF121212),
                  elevation: 0,
                  centerTitle: true,
                  iconTheme: IconThemeData(color: darkPrimary),
                ),
              ),

              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
