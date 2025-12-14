// lib/models/app_config.dart

class AppConfig {
  final int businessId;
  final String businessName;
  final String businessTypeCode; // 'VET', 'BARBER', 'PHYSIO'
  final String businessTypeName;
  final String? slug;
  final String? phone;
  final String? address;

  // Branding / opsiyonel alanlar:
  final String? logoUrl; // null olabilir, backend göndermiyorsa sorun yok
  final String?
  primaryColor; // '#1E88E5' formatında hex, şimdilik boş kalabilir
  final String? accentColor;
  final String? heroIcon; // 'PETS', 'SCISSORS' vs., şimdilik boş kalabilir

  AppConfig({
    required this.businessId,
    required this.businessName,
    required this.businessTypeCode,
    required this.businessTypeName,
    this.logoUrl,
    this.primaryColor,
    this.accentColor,
    this.heroIcon,
    this.slug,
    this.phone,
    this.address,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      businessId: json['businessId'] as int,
      businessName: json['businessName'] as String,
      businessTypeCode: json['businessTypeCode'] as String,
      businessTypeName: json['businessTypeName'] as String,
      logoUrl: json['logoUrl'] as String?, // backend göndermiyorsa null gelir
      primaryColor: json['primaryColor'] as String?,
      accentColor: json['accentColor'] as String?,
      heroIcon: json['heroIcon'] as String?,
      slug: json['slug'],
      phone: json['phone'],
      address: json['address'],
    );
  }
}
