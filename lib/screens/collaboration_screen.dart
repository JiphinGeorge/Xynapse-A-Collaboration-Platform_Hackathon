import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import '../app_router.dart';

class CollaborationScreen extends StatelessWidget {
  const CollaborationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Collaborations",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: provider.collaborations.isEmpty
          ? _emptyState()
          : _collabList(provider.collaborations, context),
    );
  }

  // ------------------------------------------------------------
  // EMPTY UI
  // ------------------------------------------------------------
  Widget _emptyState() {
    return const Center(
      child: Text(
        "You are not part of any collaborative project yet.",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  // ------------------------------------------------------------
  // COLLABORATIVE PROJECT LIST
  // ------------------------------------------------------------
  Widget _collabList(List<Project> list, BuildContext context) {
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

            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.projectDetails,
                  arguments: p,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
