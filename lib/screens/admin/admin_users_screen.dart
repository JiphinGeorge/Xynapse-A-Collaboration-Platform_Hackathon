import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/project_provider.dart';
import '../../models/user_model.dart';
import '../../db/db_helper.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    //  FIXED — prevent notifyListeners during build error
    Future.microtask(() {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    await Provider.of<ProjectProvider>(context, listen: false).refreshAll();
    setState(() => isLoading = false);
  }

  // ---------------- VIEW USER DETAILS ----------------
  void _showUserDetails(AppUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "User Details",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Name", user.name),
            _detailRow("Email", user.email),
            _detailRow("Created At", user.createdAt.substring(0, 10)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "$label:  $value",
        style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  // ---------------- DELETE USER ----------------
  void _deleteUser(AppUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          "Delete User",
          style: GoogleFonts.inter(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this user?",
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              final db = DBHelper();
              await db.deleteUser(user.id!);

              if (!mounted) return;

              await Provider.of<ProjectProvider>(
                context,
                listen: false,
              ).refreshAll();

              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    final users = provider.users;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202428), // matches admin login theme
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.amberAccent, // clearly visible
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Registered Users",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white, // visible text
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (_, index) {
                final user = users[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ---------------- PROFILE IMAGE ----------------
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.amberAccent.withOpacity(0.25),
                        backgroundImage:
                            (user.profileImage != null &&
                                user.profileImage!.isNotEmpty &&
                                File(user.profileImage!).existsSync())
                            ? FileImage(File(user.profileImage!))
                            : null,
                        child:
                            (user.profileImage == null ||
                                user.profileImage!.isEmpty ||
                                !File(user.profileImage!).existsSync())
                            ? Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),

                      const SizedBox(width: 15),

                      // USER DETAILS PREVIEW
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              user.email,
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // View Button
                      IconButton(
                        onPressed: () => _showUserDetails(user),
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.blueAccent,
                        ),
                      ),

                      // Delete Button
                      IconButton(
                        onPressed: () => _deleteUser(user),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
