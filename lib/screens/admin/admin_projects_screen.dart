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
      appBar: AppBar(
        title: const Text("All Projects"),
        backgroundColor: Colors.black87,
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
              itemBuilder: (context, index) {
                final p = projects[index];
                return Card(
                  color: const Color(0xFF1A1C1E),
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
                    trailing: Icon(
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
