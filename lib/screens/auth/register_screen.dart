import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../app_router.dart';
import '../../db/db_helper.dart';
import '../../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isRegistering = false;
  

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Focus listeners
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // registration |sql
  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    // --- VALIDATIONS -------------------------------------

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showAnimatedSnackBar(
        "Please fill all fields",
        color: const Color(0xFFE53935),
      );
      return;
    }

    if (!isValidEmail(email)) {
      _showAnimatedSnackBar(
        "Enter a valid email address",
        color: const Color(0xFFE53935),
      );
      return;
    }

    if (!isStrongPassword(password)) {
      _showAnimatedSnackBar(
        "Password must be at least 6 characters and include a number",
        color: const Color(0xFFFF7043),
      );
      return;
    }

    if (password != confirm) {
      _showAnimatedSnackBar(
        "Passwords do not match",
        color: const Color(0xFFFF7043),
      );
      return;
    }

    // -------------------------------------------------------

    setState(() => _isRegistering = true);

    final db = DBHelper();

    final user = AppUser(
      name: name,
      email: email,
      password: password,
    );

    try {
      final int userId = await db.registerUser(user);

if (!mounted) return;

// Auto Login
final prefs = await SharedPreferences.getInstance();
await prefs.setInt("current_user", userId);

// ⭐ IMPORTANT: Update provider with new user
final prov = Provider.of<ProjectProvider>(context, listen: false);
await prov.setCurrentUser(userId);
await prov.refreshAll();   // reload users + projects

setState(() => _isRegistering = false);

_showAnimatedSnackBar("Welcome, $name! 🎉", color: Colors.green);

// Navigate to Home
Navigator.pushReplacementNamed(context, Routes.home);

    } catch (e) {
      if (!mounted) return;

      setState(() => _isRegistering = false);

      _showAnimatedSnackBar(
        "Email already exists!",
        color: const Color(0xFFE53935),
      );
    }
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,4}$");
    return regex.hasMatch(email);
  }

  bool isStrongPassword(String password) {
    final regex = RegExp(r'^(?=.*\d).{6,}$');
    return regex.hasMatch(password);
  }

  void _showAnimatedSnackBar(String message, {required Color color}) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      margin: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 3),
      content: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 0, end: 1),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color == Colors.green
                    ? const Color(0xFF00C853)
                    : color == const Color(0xFFE53935)
                    ? const Color(0xFFE53935)
                    : const Color(0xFF6A11CB),
                color == Colors.green
                    ? const Color(0xFF64DD17)
                    : color == const Color(0xFFE53935)
                    ? const Color(0xFFFF7043)
                    : const Color(0xFF2575FC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                color == Colors.green
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Hero(
                    tag: 'xynapse_logo',
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Colors.cyanAccent,
                            Color.fromARGB(255, 13, 77, 188),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/xynapse_logo.png',
                              fit: BoxFit.cover,
                              height: 110,
                              width: 110,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Create an Account",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 50),

                  _buildTextField(
                    controller: _nameController,
                    hint: "Full Name",
                    icon: Icons.person_outline,
                    focusNode: _nameFocus,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    hint: "Email",
                    icon: Icons.email_outlined,
                    focusNode: _emailFocus,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    hint: "Password",
                    icon: Icons.lock_outline,
                    focusNode: _passwordFocus,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _confirmController,
                    hint: "Confirm Password",
                    icon: Icons.lock_reset,
                    focusNode: _confirmFocus,
                    isPassword: true,
                    isConfirm: true,
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 40),

                  // Register button
                  GestureDetector(
                    onTap: _isRegistering ? null : _register,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        gradient: LinearGradient(
                          colors: _isRegistering
                              ? [
                                  const Color(0xFF00C9FF),
                                  const Color(0xFF92FE9D),
                                ]
                              : [
                                  const Color(0xFF6A11CB),
                                  const Color(0xFF2575FC),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isRegistering
                                ? Colors.blueAccent.withValues(alpha: 0.4)
                                : Colors.purpleAccent.withValues(alpha: 0.3),
                            blurRadius: 18,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isRegistering
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "CREATING...",
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                "REGISTER",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Lottie.asset(
                    'assets/animations/register_animation.json',
                    height: 180,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, Routes.login);
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required FocusNode focusNode,
    bool isPassword = false,
    bool isConfirm = false,
  }) {
    final isFocused = focusNode.hasFocus;
    final isObscured = isConfirm
        ? _obscureConfirm
        : (isPassword ? _obscurePassword : false);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword || isConfirm ? isObscured : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: isFocused ? Colors.cyanAccent : Colors.white70,
          ),
          suffixIcon: (isPassword || isConfirm)
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: isFocused ? Colors.cyanAccent : Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isConfirm) {
                        _obscureConfirm = !_obscureConfirm;
                      } else {
                        _obscurePassword = !_obscurePassword;
                      }
                    });
                  },
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white60),
          filled: true,
          fillColor: isFocused
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
