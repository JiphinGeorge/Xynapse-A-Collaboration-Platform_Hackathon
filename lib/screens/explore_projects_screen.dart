import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import '../app_router.dart';

class ExploreProjectsScreen extends StatelessWidget {
  const ExploreProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);

    // Only public projects not created by the current user
    final projects = provider.projects.where(
      (p) => p.isPublic == 1 && p.creatorId != provider.currentUserId,
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Explore Projects",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: projects.isEmpty
          ? _emptyUI()
          : _projectList(projects, context),
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------
  Widget _emptyUI() {
    return const Center(
      child: Text(
        "No public projects available.",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  // ------------------------------------------------------------
  // EXPLORE PROJECT LIST
  // ------------------------------------------------------------
  Widget _projectList(List<Project> list, BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,

      itemBuilder: (context, index) {
        final p = list[index];

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          child: ListTile(
            contentPadding: const EdgeInsets.all(16),

            title: Text(
              p.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                p.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            trailing: ElevatedButton(
              onPressed: () async {
                await provider.joinProject(p.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Joined project successfully!"),
                  ),
                );
              },

              child: const Text("Join"),
            ),

            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.projectDetails,
                arguments: p,
              );
            },
          ),
        );
      },
    );
  }
}
