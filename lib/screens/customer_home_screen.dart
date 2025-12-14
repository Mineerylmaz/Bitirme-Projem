import 'package:flutter/material.dart';
import 'pet_management_screen.dart'; // en üstte diğer importlara ekle
import 'customer_appointments_screen.dart';
import '../models/app_config.dart';
import '../models/auth_user.dart';
import '../theme/business_ui_config.dart';
import 'business_booking_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'business_info_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  final AppConfig config;
  final AuthUser user;
  final String token; // ileride API çağrılarında kullanırız

  const CustomerHomeScreen({
    super.key,
    required this.config,
    required this.user,
    required this.token,
  });

  String get _heroTitle {
    switch (config.businessTypeCode) {
      case 'VET':
        return "Merhaba,\nevcil dostunun randevularını buradan yönet.";
      case 'BARBER':
        return "Merhaba,\nkuaför randevularını buradan yönet.";
      case 'PHYSIO':
        return "Merhaba,\nseanslarını buradan planla.";
      default:
        return "Merhaba,\nrandevularını buradan yönet.";
    }
  }

  String get _primaryActionText {
    switch (config.businessTypeCode) {
      case 'VET':
        return "Yeni Veteriner Randevusu";
      case 'BARBER':
        return "Yeni Kuaför Randevusu";
      case 'PHYSIO':
        return "Yeni Seans Oluştur";
      default:
        return "Yeni Randevu Oluştur";
    }
  }

  @override
  Widget build(BuildContext context) {
    final ui = getBusinessUiConfig(config);
    final isVet = config.businessTypeCode == 'VET';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: kullanıcı + işletme
              Text(
                "Hoş geldin",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                config.businessName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // Hero card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: ui.primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ui.heroIcon,
                        color: ui.primaryColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _heroTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BusinessBookingScreen(
                                    config: config,
                                    currentUser: user,
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

              const SizedBox(height: 24),

              const Text(
                "Yaklaşan Randevuların",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                      color: Colors.black.withOpacity(0.04),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: ui.primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.event, color: ui.primaryColor),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Henüz randevun yok",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Yeni bir randevu oluşturarak başlayabilirsin.",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Kısayollar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _ShortcutCard(
                    icon: Icons.event_note,
                    title: "Randevularım",
                    subtitle: "Geçmiş ve gelecek",
                    color: ui.primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CustomerAppointmentsScreen(
                                config: config,
                                token: token,
                              ),
                        ),
                      );
                    },
                  ),

                  if (isVet)
                    _ShortcutCard(
                      icon: Icons.pets,
                      title: "Evcil Hayvanlarım",
                      subtitle: "Bilgi ve geçmiş",
                      color: ui.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => PetManagementScreen(
                                  config: config,
                                  token: token,
                                ),
                          ),
                        );
                      },
                    ),

                  if (!isVet)
                    _ShortcutCard(
                      icon: Icons.bookmark_border,
                      title: "Favorilerim",
                      subtitle: "Hizmet / uzman",
                      color: ui.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FavoritesScreen(
                                  config: config,
                                  token: token,
                                ),
                          ),
                        );
                      },
                    ),

                  _ShortcutCard(
                    icon: Icons.person,
                    title: "Profilim",
                    subtitle: "Kişisel bilgiler",
                    color: ui.primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  ProfileScreen(config: config, token: token),
                        ),
                      );
                    },
                  ),

                  _ShortcutCard(
                    icon: Icons.info_outline,
                    title: "İşletme Bilgisi",
                    subtitle: "Adres ve iletişim",
                    color: ui.primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BusinessInfoScreen(config: config),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 40 - 14) / 2;

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 6),
                color: Colors.black.withOpacity(0.03),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
