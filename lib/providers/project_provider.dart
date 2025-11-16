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

  int? currentUserId; // nullable until user logs in

  // ---------------- INIT ----------------
  Future<void> init() async {
    await _loadUsers();
    await _loadPrefs();
    await refreshAll();
  }

  Future<void> _loadUsers() async {
    users = await _db.getAllUsers();
    // notifyListeners() removed (refreshAll handles notifications)
  }

  // ---------------- LOAD LOGIN ----------------
  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    currentUserId = sp.getInt('current_user'); // returns null if not found
  }

  // ---------------- SET LOGIN ----------------
  Future<void> setCurrentUser(int id) async {
    currentUserId = id;

    final sp = await SharedPreferences.getInstance();
    await sp.setInt('current_user', id);

    // When logging out (id == 0), do NOT refreshAll()
    if (id != 0) {
      await refreshAll();
    }

    notifyListeners();
  }

  // ---------------- INITIAL LETTER ----------------
  String get currentUserInitial {
    final uid = currentUserId;
    if (uid == null) return "?";

    try {
      final user = users.firstWhere((u) => u.id == uid);
      return user.name.isNotEmpty ? user.name[0].toUpperCase() : "?";
    } catch (_) {
      return "?";
    }
  }

  // ---------------- REFRESH EVERYTHING ----------------
  Future<void> refreshAll() async {
    final uid = currentUserId; // IMPORTANT: local variable promotion

    if (uid == null || uid == 0) {
      myProjects = [];
      collaborations = [];
      publicProjects = [];
      notifyListeners();
      return;
    }

    await _loadUsers();
    projects = await _db.getAllProjects();
    myProjects = await _db.getProjectsByCreator(uid);
    collaborations = await _db.getCollaborationsForUser(uid);

    publicProjects = projects.where((p) => p.isPublic == 1).toList();

    notifyListeners();
  }

  // ---------------- ADD PROJECT ----------------
  Future<int> addProject(Project p, List<int> memberIds) async {
    final id = await _db.insertProject(p);

    for (var uid in memberIds) {
      await _db.addCollaboration(id, uid);
    }

    await refreshAll();
    return id;
  }

  // ---------------- JOIN PROJECT ----------------
  Future<void> joinProject(int projectId) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _db.addCollaboration(projectId, uid);
    await refreshAll();
  }

  // ---------------- LEAVE PROJECT ----------------
  Future<void> leaveProject(int projectId) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _db.removeCollaboration(projectId, uid);
    await refreshAll();
  }

  // ---------------- GET MEMBERS ----------------
  Future<List<AppUser>> getMembers(int projectId) async {
    return await _db.getProjectMembers(projectId);
  }

  // ---------------- DELETE PROJECT ----------------
  Future<void> deleteProject(int projectId) async {
    await _db.deleteProject(projectId);
    await refreshAll();
  }

  // ---------------- UPDATE PROJECT ----------------
  Future<void> updateProject(Project p, List<int> memberIds) async {
    await _db.updateProject(p);
    await _db.setCollaborators(p.id!, memberIds);
    await refreshAll();
  }

  // ---------------- FILTERS ----------------
  List<Project> getCollabFiltered(String q, String cat) =>
      collaborations.where((p) => _filter(p, q, cat)).toList();

  List<Project> getMyFiltered(String q, String cat) =>
      myProjects.where((p) => _filter(p, q, cat)).toList();

  List<Project> getPublicFiltered(String q, String cat) =>
      publicProjects.where((p) => _filter(p, q, cat)).toList();

  bool _filter(Project p, String q, String cat) {
    final matchTitle = p.title.toLowerCase().contains(q.toLowerCase());
    final matchCat =
        cat == "All" || p.category.toLowerCase() == cat.toLowerCase();
    return matchTitle && matchCat;
  }

  // ---------------- FETCH ALL ----------------
  Future<void> fetchAllProjects() async {
    await refreshAll();
  }

  // ---------------- PUBLIC PROJECTS (READ ONLY) ----------------
  List<Project> get allPublicProjects {
    final uid = currentUserId;
    if (uid == null) return [];

    return projects
        .where((p) => p.isPublic == 1 && p.creatorId != uid)
        .toList();
  }

  Future<void> updateUserImage(String newPath) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _db.updateProfileImage(uid, newPath);
    await _loadUsers();
    // Refresh EVERYTHING so images update in all screens
    await refreshAll();

    notifyListeners();
  }
}
