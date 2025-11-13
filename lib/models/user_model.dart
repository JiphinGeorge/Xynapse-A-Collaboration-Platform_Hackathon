class AppUser {
  final int? id;
  final String name;
  final String email;
  final String password;      // NEW
  final String? department;   // NEW (optional)
  final String createdAt;     // NEW: auto timestamp

  AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.department,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'department': department,
        'created_at': createdAt,
      };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'],
        name: m['name'],
        email: m['email'],
        password: m['password'],
        department: m['department'],
        createdAt: m['created_at'],
      );
}
