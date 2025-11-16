import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';
import '../models/user_model.dart';
import 'package:xynapse/utils/fade_route.dart';
import 'add_edit_project_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  List<AppUser> members = [];
  bool loadingMembers = true;

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    final prov = Provider.of<ProjectProvider>(context, listen: false);
    members = await prov.getMembers(widget.project.id!);
    setState(() => loadingMembers = false);
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProjectProvider>(context, listen: false);

    final bool isOwner = widget.project.creatorId == prov.currentUserId;
    final bool isMember = members.any((m) => m.id == prov.currentUserId);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF0E3D72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "Project Details",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(18),
          child: ListView(
            children: [
              // ---------------- TITLE ----------------
              Text(
                widget.project.title,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _categoryBadge(widget.project.category),

              const SizedBox(height: 24),

              // ---------------- DESCRIPTION ----------------
              _sectionTitle("Description"),
              const SizedBox(height: 6),
              Text(
                widget.project.description,
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
              ),

              const SizedBox(height: 24),

              // ---------------- MEMBERS ----------------
              _sectionTitle("Members"),
              const SizedBox(height: 10),

              loadingMembers
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    )
                  : _membersList(),

              const SizedBox(height: 30),

              // ---------------- ACTION BUTTONS ----------------
              if (isOwner) _ownerActions(),

              if (!isOwner && widget.project.isPublic == 1)
                _joinOrLeaveButton(isMember, prov),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- CATEGORY LABEL ----------------
  Widget _categoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }

  // ---------------- MEMBERS LIST ----------------
  Widget _membersList() {
    if (members.isEmpty) {
      return const Text(
        "No members yet",
        style: TextStyle(color: Colors.white70),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: members.map((u) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                u.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(u.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              u.email,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------- OWNER ACTIONS (EDIT/DELETE) ----------------
  Widget _ownerActions() {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.edit, color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2575FC),
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () {
            Navigator.push(
              context,
              FadeRoute(
                page: AddEditProjectScreen(existingProject: widget.project),
              ),
            );
          },
          label: const Text(
            "Edit Project",
            style: TextStyle(color: Colors.white),
          ),
        ),

        const SizedBox(height: 12),

        ElevatedButton.icon(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () async {
            final prov = Provider.of<ProjectProvider>(context, listen: false);

            await prov.deleteProject(widget.project.id!);
            Navigator.pop(context);
          },
          label: const Text(
            "Delete Project",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ---------------- JOIN / LEAVE BUTTON ----------------
  Widget _joinOrLeaveButton(bool isMember, ProjectProvider prov) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isMember ? Colors.redAccent : const Color(0xFF2575FC),
        minimumSize: const Size.fromHeight(48),
        foregroundColor: Colors.white,
      ),
      onPressed: () async {
        if (isMember) {
          await prov.leaveProject(widget.project.id!);
        } else {
          await prov.joinProject(widget.project.id!);
        }

        await fetchMembers();
      },
      child: Text(isMember ? "Leave Project" : "Join Project"),
    );
  }

  // ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}
