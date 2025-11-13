import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Providers
import 'providers/project_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/my_projects_screen.dart';
import 'screens/collaborations_screen.dart';
import 'screens/profile_screen.dart';

// Routing
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const XynapseApp());
}

class XynapseApp extends StatelessWidget {
  const XynapseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectProvider()..init(),
      child: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Xynapse',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            // Route system for easier navigation
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: Routes.splash, // 👈 Start from SplashScreen
          );
        },
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _current = 0;

  final _pages =  [
    UserHomeScreen(),
    MyProjectsScreen(),
    CollaborationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_current],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _current,
        onTap: (i) => setState(() => _current = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'My Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Collaborations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
