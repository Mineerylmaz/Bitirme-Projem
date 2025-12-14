import 'package:flutter/material.dart';

import '../models/app_config.dart';
import '../services/api_service.dart';
import '../theme/business_ui_config.dart';
import 'business_login_screen.dart';

import '../models/login_response.dart';
import '../screens/business_home_screen.dart';
import '../screens/customer_home_screen.dart';

class BusinessRegisterScreen extends StatefulWidget {
  final AppConfig config;

  const BusinessRegisterScreen({super.key, required this.config});

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordAgainCtrl = TextEditingController();

  final ApiService _apiService = ApiService();

  bool _loading = false;
  String? _error;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      // 1) Kullanıcıyı kaydet (backend muhtemelen role=CUSTOMER oluşturuyor)
      await _apiService.registerCustomer(
        email: email,
        password: password,
        businessId: widget.config.businessId,
        // fullName: _nameCtrl.text.trim(), // backend'e eklediğinde açarsın
      );

      // 2) Hemen arkasından login ol (token + rol alacağız)
      final LoginResponse loginResp = await _apiService.login(
        email: email,
        password: password,
        businessId: widget.config.businessId,
      );

      if (!mounted) return;

      final role = loginResp.user.role;
      Widget home;

      // 3) Role göre home ekranını seç
      if (role == 'CUSTOMER') {
        home = CustomerHomeScreen(
          config: widget.config,
          user: loginResp.user,
          token: loginResp.token,
        );
      } else if (role == 'STAFF' || role == 'BUSINESS_ADMIN') {
        home = BusinessHomeScreen(
          config: widget.config,
          currentUser: loginResp.user, // 🔹 burası önemli
          token: loginResp.token, // 🔹 burası da
        );
      } else if (role == 'SUPER_ADMIN') {
        home = const Scaffold(
          body: Center(child: Text('Super Admin paneli henüz hazır değil')),
        );
      } else {
        home = const Scaffold(
          body: Center(
            child: Text(
              'Bilinmeyen rol, lütfen yöneticinizle iletişime geçin.',
            ),
          ),
        );
      }

      // 4) Tüm stack'i temizleyip direkt home'a git
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => home),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordAgainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;
    final ui = getBusinessUiConfig(cfg);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  if (cfg.logoUrl != null && cfg.logoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        cfg.logoUrl!,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: ui.primaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ui.heroIcon,
                        size: 46,
                        color: ui.primaryColor,
                      ),
                    ),

                  const SizedBox(height: 20),

                  Text(
                    ui.registerTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    ui.registerSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: "Ad soyad",
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "E-posta adresiniz",
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator:
                        (v) =>
                            v == null || !v.contains("@")
                                ? "Geçerli bir e-posta giriniz"
                                : null,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Şifreniz",
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator:
                        (v) =>
                            v == null || v.length < 4
                                ? "Şifre en az 4 karakter olmalı"
                                : null,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordAgainCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Şifreyi tekrar girin",
                      prefixIcon: const Icon(Icons.loop),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Lütfen şifreyi tekrar girin";
                      }
                      if (v != _passwordCtrl.text) {
                        return "Şifreler eşleşmiyor";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ui.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child:
                          _loading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Kayıt Ol",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  const Text("Zaten bir hesabınız var mı?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BusinessLoginScreen(config: widget.config),
                        ),
                      );
                    },
                    child: const Text(
                      "Giriş Yap",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
