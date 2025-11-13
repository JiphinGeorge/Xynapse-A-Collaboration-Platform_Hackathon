import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_users_screen.dart'; // ✅ MUST import this

/// 🌐 Centralized route management for Xynapse
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static const String adminLogin = '/adminLogin';
  static const String adminDashboard = '/adminDashboard';

  static const String adminUsers = '/admin/users'; // ✔ Optional clean constant
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case Routes.home:
        return MaterialPageRoute(builder: (_) => const UserHomeScreen());

      /// ADMIN
      case Routes.adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());

      case Routes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      case Routes.adminUsers:
        return MaterialPageRoute(builder: (_) => const AdminUsersScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                '⚠️ No route defined for ${settings.name}',
                style: const TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
            ),
          ),
        );
    }
  }
}
