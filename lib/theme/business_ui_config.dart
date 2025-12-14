import 'package:flutter/material.dart';
import '../models/app_config.dart';

class BusinessUiConfig {
  final Color primaryColor;
  final Color accentColor;
  final IconData heroIcon;
  final String loginTitle;
  final String loginSubtitle;
  final String registerTitle;
  final String registerSubtitle;

  BusinessUiConfig({
    required this.primaryColor,
    required this.accentColor,
    required this.heroIcon,
    required this.loginTitle,
    required this.loginSubtitle,
    required this.registerTitle,
    required this.registerSubtitle,
  });
}

Color _parseColor(String? hex, Color fallback) {
  if (hex == null || hex.isEmpty) return fallback;
  try {
    var v = hex.replaceAll('#', '');
    if (v.length == 6) v = 'FF$v'; // opacity ekle
    return Color(int.parse(v, radix: 16));
  } catch (_) {
    return fallback;
  }
}

IconData _iconFromHero(String? hero, String typeCode) {
  final key = (hero ?? '').toUpperCase();
  if (key == 'PETS') return Icons.pets;
  if (key == 'SCISSORS') return Icons.content_cut;
  if (key == 'PHYSIO') return Icons.accessibility_new;

  // typeCode'a göre fallback
  switch (typeCode) {
    case 'VET':
      return Icons.pets;
    case 'BARBER':
      return Icons.content_cut;
    case 'PHYSIO':
      return Icons.accessibility_new;
    default:
      return Icons.business;
  }
}

BusinessUiConfig getBusinessUiConfig(AppConfig config) {
  final primary = _parseColor(config.primaryColor, Colors.blue);
  final accent = _parseColor(config.accentColor, Colors.blueAccent);
  final icon = _iconFromHero(config.heroIcon, config.businessTypeCode);

  switch (config.businessTypeCode) {
    case 'VET':
      return BusinessUiConfig(
        primaryColor: primary,
        accentColor: accent,
        heroIcon: icon,
        loginTitle: "Tekrar Hoş Geldiniz",
        loginSubtitle:
            "Evcil dostlarınızın sağlığını takip etmek için giriş yapın",
        registerTitle: "Hesap Oluştur",
        registerSubtitle: "Pati dostlarınız için randevuları kolayca yönetin",
      );
    case 'BARBER':
      return BusinessUiConfig(
        primaryColor: primary,
        accentColor: accent,
        heroIcon: icon,
        loginTitle: "Hoş Geldiniz",
        loginSubtitle: "Saç ve sakal randevularınızı yönetmek için giriş yapın",
        registerTitle: "Yeni Müşteri Kaydı",
        registerSubtitle: "Dakikalar içinde randevu almaya başlayın",
      );
    case 'PHYSIO':
      return BusinessUiConfig(
        primaryColor: primary,
        accentColor: accent,
        heroIcon: icon,
        loginTitle: "Hoş Geldiniz",
        loginSubtitle: "Seans ve randevularınızı planlamak için giriş yapın",
        registerTitle: "Hesap Oluştur",
        registerSubtitle: "Rehabilitasyon sürecinizi daha rahat yönetin",
      );
    default:
      return BusinessUiConfig(
        primaryColor: primary,
        accentColor: accent,
        heroIcon: icon,
        loginTitle: "Hoş Geldiniz",
        loginSubtitle: "${config.businessName} için giriş yapın",
        registerTitle: "Hesap Oluştur",
        registerSubtitle: "Hizmetlerimize erişmek için kayıt olun",
      );
  }
}
