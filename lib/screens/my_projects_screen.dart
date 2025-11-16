import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';
import '../models/project_model.dart';
import 'package:xynapse/utils/fade_route.dart';
import 'package:xynapse/screens/project_details_screen.dart';
import 'package:xynapse/screens/add_edit_project_screen.dart';
import 'package:xynapse/screens/profile_screen.dart';

class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);

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

        body: CustomScrollView(
          slivers: [
            // ---------------- APP BAR ----------------
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

              title: Padding(
                padding: const EdgeInsets.only(left: 4), // cleaner left spacing
                child: Text(
                  "My Projects",
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        FadeRoute(page: const ProfileScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          provider.currentUserInitial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: Container(
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),

            // ---------------- BODY ----------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: provider.myProjects.isEmpty
                    ? _emptyUI()
                    : _projectList(provider.myProjects, context),
              ),
            ),
          ],
        ),

        // ---------------- ADD PROJECT BUTTON ----------------
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2575FC),
          foregroundColor: Colors.white,
          elevation: 5,
          onPressed: () {
            Navigator.push(
              context,
              FadeRoute(page: const AddEditProjectScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Project"),
        ),
      ),
    );
  }

  // ---------------- EMPTY UI ----------------
  Widget _emptyUI() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Text(
          "You have not created any projects yet.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ---------------- PROJECT LIST ----------------
  Widget _projectList(List<Project> projects, BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final p = projects[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              Text(
                p.title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // DESCRIPTION
              Text(
                p.description,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // ACTION BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // VIEW
                  TextButton(
                    child: const Text(
                      "View",
                      style: TextStyle(color: Color(0xFF76A9FF)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        FadeRoute(page: ProjectDetailsScreen(project: p)),
                      );
                    },
                  ),

                  // EDIT
                  TextButton(
                    child: const Text(
                      "Edit",
                      style: TextStyle(color: Color(0xFF76A9FF)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        FadeRoute(
                          page: AddEditProjectScreen(existingProject: p),
                        ),
                      );
                    },
                  ),

                  // DELETE
                  TextButton(
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onPressed: () => _deleteDialog(context, projectId: p.id!),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- DELETE DIALOG ----------------
  void _deleteDialog(BuildContext context, {required int projectId}) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F23),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        title: const Text(
          "Delete Project",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete this project?",
          style: TextStyle(color: Colors.white70),
        ),

        actions: [
          TextButton(
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.blueAccent),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () async {
              await provider.deleteProject(projectId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
