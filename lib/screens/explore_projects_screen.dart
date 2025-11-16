import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import 'package:xynapse/utils/fade_route.dart';
import 'project_details_screen.dart';
import 'profile_screen.dart';

class ExploreProjectsScreen extends StatelessWidget {
  const ExploreProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);

    final projects = provider.projects
        .where((p) => p.isPublic == 1 && p.creatorId != provider.currentUserId)
        .toList();

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
            // ----------------- APPBAR -----------------
            SliverAppBar(
              pinned: true,
              elevation: 0,
              expandedHeight: 45,

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
                "Explore Projects",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
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

              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Consumer<ProjectProvider>(
                    builder: (_, prov, __) {
                      return GestureDetector(
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
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              prov.currentUserInitial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

            // ----------------- BODY -----------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: projects.isEmpty
                    ? _emptyUI()
                    : _projectList(projects, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- EMPTY UI -----------------
  Widget _emptyUI() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Text(
          "No public projects available.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }

  // ----------------- PROJECT LIST -----------------
  Widget _projectList(List<Project> list, BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),

      itemBuilder: (context, index) {
        final p = list[index];

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
              // ---------------- TITLE ----------------
              Text(
                p.title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // ---------------- DESCRIPTION ----------------
              Text(
                p.description,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // ---------------- BUTTONS ----------------
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

                  // JOIN
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2575FC),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await provider.joinProject(p.id!);

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            content: _JoinedSnack(),
                          ),
                        );
                    },
                    child: const Text("Join"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _JoinedSnack extends StatelessWidget {
  const _JoinedSnack();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: const Text(
        "Joined project successfully!",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
