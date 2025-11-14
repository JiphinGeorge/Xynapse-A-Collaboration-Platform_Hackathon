import 'package:flutter/material.dart';
import 'models/project_model.dart';

import 'screens/add_edit_project_screen.dart';
import 'screens/main_wrapper.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/project_details_screen.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  // Admin routes
  static const String adminLogin = '/adminLogin';
  static const String adminDashboard = '/adminDashboard';
  static const String adminUsers = '/admin/users';

  // Project Routes
  static const String addProject = '/addProject';
  static const String projectDetails = '/projectDetails';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // SPLASH
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      // AUTH
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      // USER HOME
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const MainWrapper());

      // ADMIN
      case Routes.adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());

      case Routes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      case Routes.adminUsers:
        return MaterialPageRoute(builder: (_) => const AdminUsersScreen());

      // PROJECT ADD / EDIT
      case Routes.addProject:
        final Project? p = settings.arguments as Project?;
        return MaterialPageRoute(
          builder: (_) => AddEditProjectScreen(existingProject: p),
        );

      // ⭐ PROJECT DETAILS (uses arguments)
      case Routes.projectDetails:
        final project = settings.arguments as Project;
        return MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(project: project),
        );

      // UNKNOWN ROUTE
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
