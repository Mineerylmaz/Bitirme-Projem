class AuthUser {
  final int id;
  final String email;
  final String role;
  final int businessId;

  AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.businessId,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      businessId: json['business']['id'] as int, // backend’de böyle dönüyordu
    );
  }
}
