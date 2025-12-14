// lib/models/user.dart

class BusinessInfo {
  final int id;
  final String name;
  final String businessTypeCode; // 'VET', 'BARBER', ...
  final String businessTypeName;

  BusinessInfo({
    required this.id,
    required this.name,
    required this.businessTypeCode,
    required this.businessTypeName,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      businessTypeCode: json['businessTypeCode'] as String,
      businessTypeName: json['businessTypeName'] as String,
    );
  }
}

class User {
  final int id;
  final String email;
  final String role; // 'SUPER_ADMIN', 'BUSINESS_ADMIN', 'STAFF', 'CUSTOMER'
  final BusinessInfo business;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.business,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      business: BusinessInfo.fromJson(json['business']),
    );
  }
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user']),
    );
  }
}
