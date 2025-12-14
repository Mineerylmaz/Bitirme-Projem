import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../services/api_service.dart';
import '../theme/business_ui_config.dart';

class ProfileScreen extends StatefulWidget {
  final AppConfig config;
  final String token;

  const ProfileScreen({super.key, required this.config, required this.token});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _me;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final me = await _api.fetchMe(widget.token);
      if (!mounted) return;
      setState(() => _me = me);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _infoRow(String label, String value) {
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
    final ui = getBusinessUiConfig(widget.config);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(title: const Text("Profilim")),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _loadMe,
                      child: const Text("Tekrar dene"),
                    ),
                  ],
                ),
              )
              : _me == null
              ? Center(
                child: Text(
                  "Profil bulunamadı.",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header card
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
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: ui.primaryColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person, color: ui.primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (_me!["full_name"] ?? "").toString().isEmpty
                                      ? "Kullanıcı"
                                      : (_me!["full_name"] ?? "").toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (_me!["email"] ?? "-").toString(),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Details
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
                            "Hesap Bilgileri",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _infoRow(
                            "E-posta",
                            (_me!["email"] ?? "-").toString(),
                          ),
                          _infoRow("Rol", (_me!["role"] ?? "-").toString()),
                          _infoRow(
                            "Business",
                            (_me!["business_id"] ?? "-").toString(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // (MVP) Logout
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
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ui.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          // TODO: gerçek logout = token clear + login'e git
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Çıkış Yap",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
