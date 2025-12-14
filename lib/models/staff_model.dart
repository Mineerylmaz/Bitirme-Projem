class StaffModel {
  final int id;
  final int businessId;
  final String name;
  final String? title;

  // ✅ Yeni alanlar (admin panel için)
  final String? photoUrl;
  final String? phone;
  final String? email;
  final String? bio;

  StaffModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.title,
    this.photoUrl,
    this.phone,
    this.email,
    this.bio,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: _toInt(json['id']),
      businessId: _toInt(json['business_id'] ?? json['businessId']),
      name: (json['name'] ?? '').toString(),
      title: json['title']?.toString(),

      // ✅ backend snake_case: photo_url
      photoUrl: json['photo_url']?.toString() ?? json['photoUrl']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      bio: json['bio']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'title': title,
      'photo_url': photoUrl,
      'phone': phone,
      'email': email,
      'bio': bio,
    };
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
