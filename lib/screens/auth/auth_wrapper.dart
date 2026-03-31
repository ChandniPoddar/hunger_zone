import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../consumer/home_screen.dart';
import 'login_screen.dart';
import 'operator_user.dart';
import '../admin/canteen_admin_dashboard.dart';
import '../admin/nescafe_admin_dashboard.dart';
import '../admin/lipton_admin_dashboard.dart';
import '../admin/fruit_admin_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.phoneNumber == null) {
      return const LoginScreen();
    }

    // Role-based routing
    if (auth.isAdmin) {
      switch (auth.outletName) {
        case 'Nescafe':
          return const NescafeAdminDashboard();
        case 'Lipton':
          return const LiptonAdminDashboard();
        case 'Canteen':
          return const CanteenAdminDashboard();
        case 'Fruit Corner':
          return const FruitAdminDashboard();
        default:
          return const CanteenAdminDashboard();
      }
    } else if (auth.role == 'operator') {
      return const OperatorUserScreen();
    } else {
      return const HomeScreen();
    }
  }
}
