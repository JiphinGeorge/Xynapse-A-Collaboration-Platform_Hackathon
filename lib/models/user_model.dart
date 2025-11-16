class AppUser {
  final int? id;
  final String name;
  final String email;
  final String password;

  final String createdAt;
  final String? profileImage;  
  AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profileImage,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'profile_image': profileImage,
        'created_at': createdAt,
      };

 
  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'],
        name: m['name'],
        email: m['email'],
        password: m['password'],
        profileImage: m['profile_image'],
        createdAt: m['created_at'],
      );

  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? profileImage,
    String? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
