import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/auth_service.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/outlet_provider.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService.init();

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
              ChangeNotifierProvider<WishlistProvider>(
                create: (_) => WishlistProvider(),
              ),
              ChangeNotifierProvider<OutletProvider>(
                create: (_) => OutletProvider(),
              ),
            ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Hunger Zone',
                themeMode: themeProvider.themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,

              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
