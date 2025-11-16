import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../db/db_helper.dart';
import '../../models/project_model.dart';
import '../../models/user_model.dart';

class AdminProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const AdminProjectDetailsScreen({super.key, required this.project});

  @override
  State<AdminProjectDetailsScreen> createState() =>
      _AdminProjectDetailsScreenState();
}

class _AdminProjectDetailsScreenState extends State<AdminProjectDetailsScreen> {
  AppUser? creator;
  List<AppUser> collaborators = [];
  final db = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    creator = await db.getUserById(widget.project.creatorId);
    collaborators = await db.getProjectMembers(widget.project.id!);
    setState(() {});
  }

  Future<void> _updateStatus(String newStatus) async {
    final updated = widget.project.copyWith(status: newStatus);
    await db.updateProject(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Project $newStatus")),
    );

    Navigator.pop(context,true); // return to previous screen
  }

  Future<void> _deleteProject() async {
    await db.deleteProject(widget.project.id!);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Project Deleted")));

    Navigator.pop(context,true);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),

      appBar: AppBar(
        backgroundColor: const Color(0xFF151518),
        title: const Text("Project Details"),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: creator == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    p.title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // CREATOR
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.amberAccent),
                      const SizedBox(width: 8),
                      Text(
                        "By ${creator!.name}",
                        style: GoogleFonts.inter(color: Colors.white70),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // DESCRIPTION
                  Text(
                    p.description,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // INFO BOX
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1C1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amberAccent.withOpacity(0.2),
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow("Category", p.category),
                        _infoRow("Status", p.status),
                        _infoRow("Visibility",
                            p.isPublic == 1 ? "Public" : "Private"),
                        _infoRow("Created At", p.createdAt),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // COLLABORATORS
                  Text(
                    "Collaborators",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  collaborators.isEmpty
                      ? Text(
                          "No collaborators",
                          style: GoogleFonts.inter(color: Colors.white54),
                        )
                      : Column(
                          children: collaborators
                              .map(
                                (c) => ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.amber,
                                    child: Icon(Icons.person,
                                        color: Colors.black),
                                  ),
                                  title: Text(
                                    c.name,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    c.email,
                                    style:
                                        const TextStyle(color: Colors.white54),
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                  const SizedBox(height: 30),

                  // ADMIN ACTIONS
                  if (p.status == "pending") ...[
                    _actionButton(
                      text: "Approve",
                      color: Colors.greenAccent,
                      onTap: () => _updateStatus("approved"),
                    ),
                    const SizedBox(height: 12),
                    _actionButton(
                      text: "Reject",
                      color: Colors.redAccent,
                      onTap: () => _updateStatus("rejected"),
                    ),
                  ],

                  const SizedBox(height: 20),

                  _actionButton(
                    text: "Delete Project",
                    color: Colors.red,
                    onTap: _deleteProject,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
