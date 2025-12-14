import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../models/auth_user.dart';
import '../theme/business_ui_config.dart';
import 'business_booking_screen.dart';

class BusinessHomeScreen extends StatelessWidget {
  final AppConfig config;
  final AuthUser currentUser;
  final String token;

  const BusinessHomeScreen({
    super.key,
    required this.config,
    required this.currentUser,
    required this.token,
  });

  // --------- Metinler ---------

  String get _subtitle {
    switch (config.businessTypeCode) {
      case 'VET':
        return "Kliniğinize hoş geldiniz.\nBugün sizi 5 randevu bekliyor.";
      case 'BARBER':
        return "Kuaförünüze hoş geldiniz.\nBugün sizi 5 randevu bekliyor.";
      case 'PHYSIO':
        return "Kliniğinize hoş geldiniz.\nBugün sizi 5 seans bekliyor.";
      default:
        return "İşletmenize hoş geldiniz.\nBugün sizi 5 randevu bekliyor.";
    }
  }

  String get _heroTitle {
    switch (config.businessTypeCode) {
      case 'VET':
        return "Kliniğinize hoş geldiniz.";
      case 'BARBER':
        return "Kuaförünüze hoş geldiniz.";
      case 'PHYSIO':
        return "Kliniğinize hoş geldiniz.";
      default:
        return "İşletmenize hoş geldiniz.";
    }
  }

  String get _heroSubtitle {
    switch (config.businessTypeCode) {
      case 'PHYSIO':
        return "Bugün sizi 5 seans bekliyor.";
      default:
        return "Bugün sizi 5 randevu bekliyor.";
    }
  }

  String get _primaryActionText {
    switch (config.businessTypeCode) {
      case 'VET':
        return "Yeni Randevu Ekle";
      case 'BARBER':
        return "Yeni Randevu Ekle";
      case 'PHYSIO':
        return "Yeni Seans Ekle";
      default:
        return "Yeni Randevu Ekle";
    }
  }

  String get _secondarySectionTitle {
    switch (config.businessTypeCode) {
      case 'PHYSIO':
        return "Hızlı İşlemler";
      default:
        return "Hızlı İşlemler";
    }
  }

  List<String> get _quickActions {
    switch (config.businessTypeCode) {
      case 'VET':
        return ["Müşteri Listesi", "Hizmetler", "Raporlar", "Ayarlar"];
      case 'BARBER':
        return ["Müşteri Listesi", "Hizmetler", "Raporlar", "Ayarlar"];
      case 'PHYSIO':
        return ["Danışanlar", "Seans Planları", "Raporlar", "Ayarlar"];
      default:
        return ["Randevularım", "Hizmetler", "Raporlar", "Ayarlar"];
    }
  }

  String _quickActionSubtitle(String label) {
    switch (label) {
      case "Müşteri Listesi":
      case "Danışanlar":
        return "Yönet";
      case "Hizmetler":
      case "Seans Planları":
        return "Yönet";
      case "Raporlar":
        return "Görüntüle";
      case "Ayarlar":
        return "Yapılandır";
      case "Randevularım":
        return "Listele";
      default:
        return "";
    }
  }

  IconData _quickActionIcon(String label) {
    switch (label) {
      case "Müşteri Listesi":
      case "Danışanlar":
        return Icons.people;
      case "Hizmetler":
      case "Seans Planları":
        return Icons.content_cut;
      case "Raporlar":
        return Icons.bar_chart;
      case "Ayarlar":
        return Icons.settings;
      case "Randevularım":
        return Icons.event;
      default:
        return Icons.circle;
    }
  }

  String get _todayLabel {
    final now = DateTime.now();
    const days = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar",
    ];
    const months = [
      "Ocak",
      "Şubat",
      "Mart",
      "Nisan",
      "Mayıs",
      "Haziran",
      "Temmuz",
      "Ağustos",
      "Eylül",
      "Ekim",
      "Kasım",
      "Aralık",
    ];

    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];

    return "${now.day} $monthName $dayName";
  }

  @override
  Widget build(BuildContext context) {
    final ui = getBusinessUiConfig(config);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hoş geldiniz",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          config.businessName.isEmpty
                              ? "İşletme Adı"
                              : config.businessName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (config.logoUrl != null && config.logoUrl!.isNotEmpty)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: ui.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(config.logoUrl!, fit: BoxFit.cover),
                    )
                  else
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: ui.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(ui.heroIcon, color: Colors.white, size: 28),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // HERO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: ui.primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ui.heroIcon,
                        color: ui.primaryColor,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _heroTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _heroSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BusinessBookingScreen(
                                    config: config,
                                    currentUser: currentUser,
                                    token: token,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ui.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _primaryActionText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // BUGÜNKÜ RANDEVU
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Bugünkü Randevu",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _todayLabel,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                      color: Colors.black.withOpacity(0.04),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: ui.primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.event_available,
                        color: ui.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Henüz randevu bulunmuyor",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Yeni bir randevu ekleyerek başlayın.",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // HIZLI İŞLEMLER
              Text(
                _secondarySectionTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children:
                    _quickActions.map((label) {
                      final width =
                          (MediaQuery.of(context).size.width - 40 - 16) / 2;
                      return SizedBox(
                        width: width,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                                color: Colors.black.withOpacity(0.03),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              // TODO: ilgili ekrana yönlendirme
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: ui.primaryColor.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _quickActionIcon(label),
                                    color: ui.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _quickActionSubtitle(label),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
