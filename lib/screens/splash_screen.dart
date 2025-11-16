import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'auth/login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 🎨 Background gradient animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 60, 2, 117),
      end: const Color.fromARGB(255, 5, 32, 79),
    ).animate(_bgController);

    // 🚀 Logo scale animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _logoController.forward();

    // ⏱ Navigate after delay with fade transition
    Timer(const Duration(seconds: 5), () {
      _navigateWithFade(context);
    });
  }

  // 🌈 Fade transition navigation
  // 🌈 Fade transition navigation (Now points to real LoginScreen)
void _navigateWithFade(BuildContext context) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 900),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginScreen(),
      // transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //   return FadeTransition(opacity: animation, child: child);
      // },

        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        // transitionsBuilder: (context, animation, secondaryAnimation, child) {
        //   return ScaleTransition(scale: animation, child: child);
        // },
    ),
  );
}


  

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _colorAnimation.value ??
                      const Color.fromARGB(255, 91, 14, 175),
                  const Color.fromARGB(255, 5, 44, 112),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                   Hero(
  tag: 'xynapse_logo',
  child: CircleAvatar(
    radius: 70,
    backgroundColor: Colors.white,
    child: ClipOval(
      child: Image.asset(
        'assets/images/xynapse_logo.png',
        height: 140,
        fit: BoxFit.cover,
      ),
    ),
  ),
),



                    const SizedBox(height: 25),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Colors.cyanAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        "Xynapse",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Connect • Create • Collaborate",
                      style: TextStyle(
                        color: Color.fromARGB(211, 255, 255, 255),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // ⚡ Lottie Loader Animation
                    Lottie.asset(
                      'assets/animations/xynapse_loader.json',
                      height: 100,
                      repeat: true,
                      animate: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
