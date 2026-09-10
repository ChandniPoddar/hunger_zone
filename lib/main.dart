import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/outlet_provider.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization info: $e");
  }

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
