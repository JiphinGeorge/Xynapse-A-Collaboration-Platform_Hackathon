import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'xynapse.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ----------------------------------------------------------------------
  //                          TABLE CREATION
  // ----------------------------------------------------------------------

  Future<void> _onCreate(Database db, int version) async {
    // USERS TABLE
    // USERS TABLE
    await db.execute('''
  CREATE TABLE users(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT UNIQUE,
    password TEXT,
    created_at TEXT,
    profile_image TEXT
  )
''');

    // ADMIN TABLE
    await db.execute('''
      CREATE TABLE admin(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.insert("admin", {
      "email": "admin@xynapse.com",
      "password": "admin123",
    });

    // PROJECTS TABLE
    await db.execute('''
      CREATE TABLE projects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        creator_id INTEGER,
        category TEXT,
        status TEXT,
        is_public INTEGER,
        created_at TEXT
      )
    ''');

    // COLLABORATIONS TABLE
    await db.execute('''
      CREATE TABLE collaborations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER,
        user_id INTEGER
      )
    ''');

    // FEEDBACK TABLE
    await db.execute('''
      CREATE TABLE feedback(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        message TEXT,
        created_at TEXT
      )
    ''');

    // ACTIVITY LOG
    await db.execute('''
      CREATE TABLE activity_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT,
        user_id INTEGER,
        timestamp TEXT
      )
    ''');

    // -------------------------------------------------------------------
    // Insert Dummy Users
    // -------------------------------------------------------------------
    final users = [
      AppUser(name: 'Akhil', email: 'akhil@example.com', password: '123456'),
      AppUser(name: 'Merin', email: 'merin@example.com', password: '123456'),
      AppUser(name: 'Ankith', email: 'ankith@example.com', password: '123456'),
      AppUser(
        name: 'Sivalekshmi',
        email: 'sivalekshmi@example.com',
        password: '123456',
      ),
      AppUser(name: 'Jiphin', email: 'jiphin@example.com', password: '123456'),
    ];

    for (var u in users) {
      await db.insert('users', u.toMap());
    }

    // Add sample project
    await db.insert('projects', {
      'title': 'Campus Cleanup',
      'description': 'Organize a campus cleaning drive.',
      'creator_id': 1,
      'category': 'Social',
      'status': 'Active',
      'is_public': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Add sample collaborators
    await db.insert('collaborations', {'project_id': 1, 'user_id': 2});
    await db.insert('collaborations', {'project_id': 1, 'user_id': 3});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await _safeAddColumn(db, "users", "profile_image", "TEXT");
      await _safeAddColumn(db, "users", "created_at", "TEXT");
    }
  }

  Future<void> _safeAddColumn(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((c) => c['name'] == column);

    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type;');
    }
  }

  // ----------------------------------------------------------------------
  //                           AUTH METHODS
  // ----------------------------------------------------------------------

  Future<int> registerUser(AppUser user) async {
    final db = await database;
    await logActivity("New user registered: ${user.email}", userId: user.id);

    return await db.insert('users', user.toMap());
  }

  Future<AppUser?> loginUser(String email, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    await logActivity("User logged in: $email");

    return res.isNotEmpty ? AppUser.fromMap(res.first) : null;
  }

  Future<bool> loginAdmin(String email, String password) async {
    final db = await database;
    final res = await db.query(
      'admin',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    await logActivity("Admin logged in");

    return res.isNotEmpty;
  }

  // ----------------------------------------------------------------------
  //                        PROJECT CRUD
  // ----------------------------------------------------------------------

  Future<int> insertProject(Project project) async {
    final db = await database;
    await logActivity(
      "Project created: ${project.title}",
      userId: project.creatorId,
    );

    return await db.insert('projects', project.toMap());
  }

  Future<List<Project>> getAllProjects() async {
    final db = await database;
    final res = await db.query('projects', orderBy: "created_at DESC");
    return res.map((e) => Project.fromMap(e)).toList();
  }

  Future<List<Project>> getProjectsByCreator(int userId) async {
    final db = await database;
    final res = await db.query(
      'projects',
      where: 'creator_id = ?',
      whereArgs: [userId],
      orderBy: "created_at DESC",
    );
    return res.map((e) => Project.fromMap(e)).toList();
  }

  Future<List<Project>> getCollaborationsForUser(int userId) async {
    final db = await database;
    final res = await db.rawQuery(
      '''
      SELECT p.* FROM projects p
      JOIN collaborations c ON c.project_id = p.id
      WHERE c.user_id = ? AND p.creator_id != ?
    ''',
      [userId, userId],
    );

    return res.map((e) => Project.fromMap(e)).toList();
  }

  // ----------------------------------------------------------------------
  //                     COLLABORATION HANDLING
  // ----------------------------------------------------------------------

  Future<List<AppUser>> getProjectMembers(int projectId) async {
    final db = await database;
    final res = await db.rawQuery(
      '''
      SELECT u.* FROM users u
      JOIN collaborations c ON c.user_id = u.id
      WHERE c.project_id = ?
    ''',
      [projectId],
    );

    return res.map((e) => AppUser.fromMap(e)).toList();
  }

  Future<int> addCollaboration(int projectId, int userId) async {
    final db = await database;

    final exists = await db.query(
      'collaborations',
      where: "project_id = ? AND user_id = ?",
      whereArgs: [projectId, userId],
    );

    if (exists.isNotEmpty) return 0;

    int result = await db.insert('collaborations', {
      'project_id': projectId,
      'user_id': userId,
    });

    // 🔥 LOG ACTIVITY
    await logActivity("User $userId joined Project $projectId", userId: userId);

    return result;
  }

  Future<int> removeCollaboration(int projectId, int userId) async {
    final db = await database;
    return await db.delete(
      'collaborations',
      where: "project_id = ? AND user_id = ?",
      whereArgs: [projectId, userId],
    );
  }

  Future<int> deleteProject(int id) async {
    final db = await database;

    await db.delete('collaborations', where: 'project_id = ?', whereArgs: [id]);
    int result = await db.delete('projects', where: 'id = ?', whereArgs: [id]);

    // 🔥 LOG ACTIVITY
    await logActivity("Project deleted (ID: $id)");

    return result;
  }

  // ----------------------------------------------------------------------
  //                        ADMIN DASHBOARD COUNTS
  // ----------------------------------------------------------------------

  Future<int> countUsers() async {
    final db = await database;
    final res = await db.rawQuery("SELECT COUNT(*) AS total FROM users");
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> countProjects() async {
    final db = await database;
    final res = await db.rawQuery("SELECT COUNT(*) AS total FROM projects");
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> countFeedback() async {
    final db = await database;
    final res = await db.rawQuery("SELECT COUNT(*) AS total FROM feedback");
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> countPendingProjects() async {
    final db = await database;
    final res = await db.rawQuery(
      "SELECT COUNT(*) AS total FROM projects WHERE status = 'pending'",
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  // ----------------------------------------------------------------------
  //                           USER LIST
  // ----------------------------------------------------------------------

  Future<List<AppUser>> getAllUsers() async {
    final db = await database;
    final res = await db.query("users");
    return res.map((e) => AppUser.fromMap(e)).toList();
  }

  // ---------------------------
  // UPDATE USER
  // ---------------------------
  Future<int> updateUser(AppUser user) async {
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ---------------------------
  // DELETE USER
  // ---------------------------
  Future<int> deleteUser(int userId) async {
    final db = await database;
    return db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  // ---------------------------
  // GET USER BY ID (optional)
  // ---------------------------
  Future<AppUser?> getUserById(int id) async {
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? AppUser.fromMap(res.first) : null;
  }

  Future<int> updateProject(Project p) async {
    final db = await database;

    int result = await db.update(
      'projects',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );

    // 🔥 LOG ACTIVITY
    await logActivity("Project updated: ${p.title}", userId: p.creatorId);

    return result;
  }

  // ---------------- GET COLLABORATORS ----------------
  Future<List<int>> getCollaboratorIds(int projectId) async {
    final db = await database;
    final res = await db.query(
      'collaborations',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );

    return res.map((e) => e['user_id'] as int).toList();
  }

  // ---------------- REPLACE COLLABORATORS ----------------
  Future<void> setCollaborators(int projectId, List<int> userIds) async {
    final db = await database;

    // delete old
    await db.delete(
      'collaborations',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );

    // add new
    for (var uid in userIds) {
      await db.insert('collaborations', {
        'project_id': projectId,
        'user_id': uid,
      });
    }
  }

  Future<void> logActivity(String action, {int? userId}) async {
    final db = await database;

    await db.insert("activity_logs", {
      "action": action,
      "user_id": userId ?? 0,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    final db = await database;

    return await db.query("activity_logs", orderBy: "id DESC", limit: 20);
  }

  //Feedback method
  Future<int> insertFeedback(int userId, String message) async {
    final db = await database;

    await logActivity("Feedback submitted", userId: userId);

    return await db.insert("feedback", {
      "user_id": userId,
      "message": message,
      "created_at": DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllFeedback() async {
    final db = await database;

    return await db.rawQuery('''
    SELECT feedback.id, feedback.message, feedback.created_at,
           users.name, users.email
    FROM feedback
    LEFT JOIN users ON feedback.user_id = users.id
    ORDER BY feedback.id DESC
  ''');
  }

  Future<int> deleteFeedback(int feedbackId) async {
    final db = await database;

    await logActivity("Feedback deleted (ID: $feedbackId)");

    return await db.delete(
      'feedback',
      where: 'id = ?',
      whereArgs: [feedbackId],
    );
  }

  // ----------------------------------------------------------------------
  //                        PROFILE IMAGE
  // ----------------------------------------------------------------------
  Future<int> updateProfileImage(int userId, String path) async {
    final db = await database;

    return await db.update(
      'users',
      {'profile_image': path},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Count users created in last 24 hours
  Future<int> countNewUsersToday() async {
    final db = await database;
    final res = await db.rawQuery('''
    SELECT COUNT(*) AS total FROM users
    WHERE created_at >= datetime('now', '-1 day')
  ''');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  // Count projects created in last 24 hours
  Future<int> countNewProjectsToday() async {
    final db = await database;
    final res = await db.rawQuery('''
    SELECT COUNT(*) AS total FROM projects
    WHERE created_at >= datetime('now', '-1 day')
  ''');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  // Count feedback messages in last 24 hours
  Future<int> countFeedbackToday() async {
    final db = await database;
    final res = await db.rawQuery('''
    SELECT COUNT(*) AS total FROM feedback
    WHERE created_at >= datetime('now', '-1 day')
  ''');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  // Count activity logs in last 24 hours
  Future<int> countActivityToday() async {
    final db = await database;
    final res = await db.rawQuery('''
    SELECT COUNT(*) AS total FROM activity_logs
    WHERE timestamp >= datetime('now', '-1 day')
  ''');
    return Sqflite.firstIntValue(res) ?? 0;
  }
}
