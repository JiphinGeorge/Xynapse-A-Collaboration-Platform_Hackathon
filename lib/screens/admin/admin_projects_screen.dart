import 'package:flutter/material.dart';
import '../../db/db_helper.dart';
import '../../models/project_model.dart';

class AdminProjectsScreen extends StatefulWidget {
  const AdminProjectsScreen({super.key});

  @override
  State<AdminProjectsScreen> createState() => _AdminProjectsScreenState();
}

class _AdminProjectsScreenState extends State<AdminProjectsScreen> {
  List<Project> projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final db = DBHelper();
    projects = await db.getAllProjects();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: const Color(0xFF202428), // Matches admin theme
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.amberAccent,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          "All Projects",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: projects.isEmpty
          ? const Center(
              child: Text(
                "No projects found",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: projects.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (context, index) {
                final p = projects[index];

                return Card(
                  color: const Color(0xFF1A1C1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  child: ListTile(
                    title: Text(
                      p.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      p.description,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.amberAccent,
                      size: 18,
                    ),
                    onTap: () async {
                      final refresh = await Navigator.pushNamed(
                        context,
                        '/admin/projectDetails',
                        arguments: p,
                      );
                      if (refresh == true) {
                        _loadProjects(); // reload list after update/delete
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
