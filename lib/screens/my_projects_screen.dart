import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import '../app_router.dart';


class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Projects",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addProject);
        },
        child: const Icon(Icons.add),
      ),

      body: provider.myProjects.isEmpty
          ? _emptyUI()
          : _projectList(provider.myProjects, context),
    );
  }

  // ------------------------------------------------------------
  // EMPTY UI (No Projects)
  // ------------------------------------------------------------
  Widget _emptyUI() {
    return const Center(
      child: Text(
        "You have not created any projects yet.",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  // ------------------------------------------------------------
  // PROJECT LIST
  // ------------------------------------------------------------
  Widget _projectList(List<Project> projects, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,

      itemBuilder: (context, index) {
        final p = projects[index];

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
                fontSize: 18, fontWeight: FontWeight.bold
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

            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "view") {
                  Navigator.pushNamed(
                    context,
                    Routes.projectDetails,
                    arguments: p,
                  );
                } else if (value == "edit") {
                  Navigator.pushNamed(
                    context,
                    Routes.addProject,
                    arguments: p,
                  );
                } else if (value == "delete") {
                  _deleteDialog(context, p.id!);
                }
              },

              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "view",
                  child: Text("View"),
                ),
                const PopupMenuItem(
                  value: "edit",
                  child: Text("Edit"),
                ),
                const PopupMenuItem(
                  value: "delete",
                  child: Text("Delete"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // DELETE CONFIRMATION DIALOG
  // ------------------------------------------------------------
  void _deleteDialog(BuildContext context, int projectId) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Project"),
        content: const Text("Are you sure you want to delete this project?"),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () async {
              await provider.deleteProject(projectId);
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
