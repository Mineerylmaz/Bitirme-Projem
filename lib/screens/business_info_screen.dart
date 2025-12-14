import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../theme/business_ui_config.dart';

class BusinessInfoScreen extends StatelessWidget {
  final AppConfig config;

  const BusinessInfoScreen({super.key, required this.config});

  String get _typeLabel {
    switch (config.businessTypeCode) {
      case "VET":
        return "Veteriner";
      case "BARBER":
        return "Kuaför";
      case "PHYSIO":
        return "Fizyoterapi";
      default:
        return "İşletme";
    }
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ui = getBusinessUiConfig(config);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(title: const Text("İşletme Bilgisi")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    color: Colors.black.withOpacity(0.04),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (config.logoUrl != null && config.logoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        config.logoUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: ui.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        ui.heroIcon,
                        color: ui.primaryColor,
                        size: 30,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.businessName.isEmpty
                              ? "İşletme"
                              : config.businessName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _typeLabel,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    color: Colors.black.withOpacity(0.04),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Detaylar",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  _line("Slug", config.slug ?? "-"),
                  _line("ID", config.businessId.toString()),
                  _line("Tip", config.businessTypeCode ?? "-"),

                  // Eğer AppConfig’te yoksa şimdilik '-' gösteriyoruz.
                  _line("Telefon", config.phone ?? "-"),
                  _line("Adres", config.address ?? "-"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
