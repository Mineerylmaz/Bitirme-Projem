class BusinessType {
  final int id;
  final String code;
  final String name;

  BusinessType({required this.id, required this.code, required this.name});

  factory BusinessType.fromJson(Map<String, dynamic> json) {
    return BusinessType(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }
}
