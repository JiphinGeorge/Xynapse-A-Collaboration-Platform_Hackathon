import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation when entering Profile screen
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> logout(BuildContext context) async {
    // Fade out animation
    await _fadeController.reverse();

    final sp = await SharedPreferences.getInstance();
    await sp.remove('current_user');

    Provider.of<ProjectProvider>(context, listen: false).setCurrentUser(0);

    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: _fadeController,
            curve: Curves.easeInOutBack,
          ),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1C1C1C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Logout",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "Are you sure you want to logout from Xynapse?",
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // close dialog
                  await logout(context); // smooth fade-out logout
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProjectProvider>(context);
    final currentUserId = prov.currentUserId;

    if (currentUserId == 0) {
      Future.microtask(() {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
      });
      return const SizedBox.shrink();
    }

    final users = prov.users.where((u) => u.id == currentUserId).toList();
    if (users.isEmpty) return const SizedBox.shrink();

    final user = users.first;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),

        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text("Profile", style: GoogleFonts.poppins()),
          centerTitle: true,
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Avatar
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                user.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),
              Text(
                user.email,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15),
              ),

              const SizedBox(height: 20),
              const Divider(color: Colors.white24),

              const SizedBox(height: 20),

              _infoTile("User ID", user.id.toString(), Icons.person),
              const SizedBox(height: 10),
              _infoTile(
                "My Projects",
                prov.myProjects.length.toString(),
                Icons.folder_open,
              ),
              const SizedBox(height: 10),
              _infoTile(
                "Collaborations",
                prov.collaborations.length.toString(),
                Icons.group_work,
              ),

              const Spacer(),

              // Logout Button
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 30,
                  ),
                ),
                onPressed: () => _confirmLogout(context),
                label: const Text("Logout"),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
