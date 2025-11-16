import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/project_provider.dart';
import '../app_router.dart';
import '../../db/db_helper.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.value = 1;
  }

  // PICK IMAGE
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final prov = Provider.of<ProjectProvider>(context, listen: false);
    await prov.updateUserImage(picked.path);

    setState(() {});
  }

  // LOGOUT
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Do you want to logout?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final sp = await SharedPreferences.getInstance();
              await sp.remove("current_user");
              await Provider.of<ProjectProvider>(
                context,
                listen: false,
              ).setCurrentUser(0);

              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.login,
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // INFO TILE
  Widget _infoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:  0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha:  0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues( alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProjectProvider>(context);
    final uid = prov.currentUserId ?? 0;

    if (uid == 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Navigator.pushReplacementNamed(context, Routes.login),
      );
      return const SizedBox.shrink();
    }

    final user = prov.users.firstWhere(
      (u) => u.id == uid,
      orElse: () => AppUser(
        id: 0,
        name: "Guest",
        email: "guest@xynapse.dev",
        password: "-",
      ),
    );

    return FadeTransition(
      opacity: _fade,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF0E3D72)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  expandedHeight: 40,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  centerTitle: true,
                  title: Text(
                    "My Profile",
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                // BODY
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ---------------- AVATAR ----------------
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha:  0.8),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:  0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white.withValues(alpha:  0.12),
                              backgroundImage:
                                  (user.profileImage != null &&
                                      user.profileImage!.isNotEmpty &&
                                      File(user.profileImage!).existsSync())
                                  ? FileImage(File(user.profileImage!))
                                  : null,
                              child:
                                  (user.profileImage == null ||
                                      user.profileImage!.isEmpty)
                                  ? Text(
                                      user.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 36,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: _pickImage,
                          child: Text(
                            "Change Photo",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:  0.8),
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          user.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.email,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 25),

                        _infoTile("User ID", user.id.toString(), Icons.badge),
                        _infoTile(
                          "My Projects",
                          prov.myProjects.length.toString(),
                          Icons.folder,
                        ),
                        _infoTile(
                          "Collaborations",
                          prov.collaborations.length.toString(),
                          Icons.groups,
                        ),

                        const SizedBox(height: 20),

                        _glassButton(
                          text: "Send Feedback",
                          icon: Icons.feedback_outlined,
                          onTap: () => _openFeedbackDialog(context, user.id!),
                        ),

                        const SizedBox(height: 12),

                        _glassButton(
                          text: "Logout",
                          icon: Icons.logout,
                          onTap: () => _confirmLogout(context),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:  0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues( alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FEEDBACK DIALOG
  void _openFeedbackDialog(BuildContext context, int userId) {
    final msgC = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Send Feedback",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: TextField(
          controller: msgC,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Type your feedback...",
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha:  0.07),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () async {
              if (msgC.text.trim().isEmpty) return;

              await DBHelper().insertFeedback(userId, msgC.text.trim());
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Feedback submitted")),
              );
            },
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }
}
