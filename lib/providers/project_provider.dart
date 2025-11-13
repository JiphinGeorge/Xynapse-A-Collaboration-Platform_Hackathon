import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/db_helper.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';

class ProjectProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();

  List<Project> projects = [];
  List<Project> myProjects = [];
  List<Project> collaborations = [];
  List<AppUser> users = [];
  List<Project> publicProjects = [];
  // ------------------------------------------------------------
// PUBLIC PROJECTS (from other users)
// ------------------------------------------------------------
List<Project> get allPublicProjects {
  return projects.where(
    (p) => p.isPublic == 1 && p.creatorId != currentUserId,
  ).toList();
}



  int currentUserId = 0;  // Updated (default is 0 → no user)

  Future<void> init() async {
    await _loadUsers();
    await _loadPrefs();
    await refreshAll();
  }

  // --- Load all users from SQLite
  Future<void> _loadUsers() async {
    users = await _db.getAllUsers();
    notifyListeners();
  }

  // --- Load logged-in user from SharedPrefs
  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    currentUserId = sp.getInt('current_user') ?? 0;
  }

  // --- Change logged-in user
  Future<void> setCurrentUser(int id) async {
    currentUserId = id;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('current_user', id);

    await refreshAll();
    notifyListeners();
  }

  // --- Refresh all dashboard/project data
  Future<void> refreshAll() async {
  if (currentUserId == 0) return;

  projects = await _db.getAllProjects();
  myProjects = await _db.getProjectsByCreator(currentUserId);

  // Collaborative projects
  collaborations = await _db.getCollaborationsForUser(currentUserId);

  // ⭐ Public projects (is_public == 1)
  publicProjects = projects.where((p) => p.isPublic == 1).toList();

  notifyListeners();
}


  // --- Create project & assign members
  Future<int> addProject(Project p, List<int> memberIds) async {
    final id = await _db.insertProject(p);

    for (var uid in memberIds) {
      await _db.addCollaboration(id, uid);
    }

    await refreshAll();
    return id;
  }

  // --- Join project
  Future<void> joinProject(int projectId) async {
    await _db.addCollaboration(projectId, currentUserId);
    await refreshAll();
  }

  // --- Leave project
  Future<void> leaveProject(int projectId) async {
    await _db.removeCollaboration(projectId, currentUserId);
    await refreshAll();
  }

  // --- Get project members
  Future<List<AppUser>> getMembers(int projectId) async {
    return await _db.getProjectMembers(projectId);
  }

  // --- Delete project
  Future<void> deleteProject(int projectId) async {
    await _db.deleteProject(projectId);
    await refreshAll();
  }
}
