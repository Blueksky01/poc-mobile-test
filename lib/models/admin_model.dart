class AdminUser {
  final int id;
  final String username;
  final String name;
  final String role;

  const AdminUser({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role,
    };
  }
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final AdminUser admin;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.admin,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      admin: AdminUser.fromJson(
        (json['admin'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'admin': admin.toJson(),
    };
  }
}
