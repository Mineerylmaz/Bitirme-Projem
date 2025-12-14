import 'package:flutter/material.dart';

import '../models/app_config.dart';
import '../services/api_service.dart';
import '../theme/business_ui_config.dart';
import '../screens/admin_home_screen.dart';

import 'business_register_screen.dart';
import 'customer_home_screen.dart';
import 'business_home_screen.dart';

class BusinessLoginScreen extends StatefulWidget {
  final AppConfig config;

  const BusinessLoginScreen({super.key, required this.config});

  @override
  State<BusinessLoginScreen> createState() => _BusinessLoginScreenState();
}

class _BusinessLoginScreenState extends State<BusinessLoginScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _apiService.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        businessId: widget.config.businessId,
      );

      final role = result.user.role;

      if (!mounted) return;

      if (role == 'CUSTOMER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => CustomerHomeScreen(
                  config: widget.config,
                  user: result.user,
                  token: result.token,
                ),
          ),
        );
      } else if (role == 'STAFF') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => BusinessHomeScreen(
                  config: widget.config,
                  currentUser: result.user,
                  token: result.token,
                ),
          ),
        );
      } else if (role == 'BUSINESS_ADMIN') {
        // 🔹 Klinlik sahibi admin paneli
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => AdminHomeScreen(
                  config: widget.config,
                  user: result.user,
                  token: result.token,
                ),
          ),
        );
      } else {
        // SUPER_ADMIN veya diğer roller için şimdilik basit ekran
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => const Scaffold(
                  body: Center(
                    child: Text('Bu rol için ekran henüz hazır değil'),
                  ),
                ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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

                  // Logo varsa logo, yoksa hero icon
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
                    ui.loginTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    ui.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 32),

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

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text("Şifremi Unuttum"),
                    ),
                  ),

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
                      onPressed: _loading ? null : _handleLogin,
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
                                "Giriş Yap",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  const Text("Hesabınız yok mu?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  BusinessRegisterScreen(config: widget.config),
                        ),
                      );
                    },
                    child: const Text(
                      "Kayıt Ol",
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
