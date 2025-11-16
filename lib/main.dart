import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Providers
import 'providers/project_provider.dart';

// Routing
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Load provider BEFORE the UI starts
  final projectProvider = ProjectProvider();
  await projectProvider.init(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: projectProvider),
      ],
      child: const XynapseApp(),
    ),
  );
}

class XynapseApp extends StatelessWidget {
  const XynapseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xynapse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: Routes.splash,
    );
  }
}
