import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';
import '../models/user_model.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text("Project Details", style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(widget.project.title,
                style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),

            const SizedBox(height: 12),

            // Category Badge
            _categoryBadge(widget.project.category),

            const SizedBox(height: 20),

            // DESCRIPTION
            Text("Description",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text(widget.project.description,
                style:
                    GoogleFonts.poppins(fontSize: 15, color: Colors.white70)),

            const SizedBox(height: 20),

            // MEMBERS
            Text("Members",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 10),

            loadingMembers
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent))
                : _membersList(),

            const SizedBox(height: 30),

            // ACTION BUTTONS
            if (isOwner) _ownerActions(),
            if (!isOwner && widget.project.isPublic == 1)
              _joinOrLeaveButton(isMember, prov),
          ],
        ),
      ),
    );
  }

  Widget _categoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(category,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _membersList() {
    if (members.isEmpty) {
      return const Text("No members yet",
          style: TextStyle(color: Colors.white70));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: members
          .map(
            (u) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(u.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(u.name, style: const TextStyle(color: Colors.white)),
              subtitle:
                  Text(u.email, style: const TextStyle(color: Colors.white70)),
            ),
          )
          .toList(),
    );
  }

  Widget _ownerActions() {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            Navigator.pushNamed(context, "/editProject",
                arguments: widget.project);
          },
          label: const Text("Edit Project"),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete_outline),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () {
            Provider.of<ProjectProvider>(context, listen: false)
                .deleteProject(widget.project.id!);
            Navigator.pop(context);
          },
          label: const Text("Delete Project"),
        ),
      ],
    );
  }

  Widget _joinOrLeaveButton(bool isMember, ProjectProvider prov) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
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
}
