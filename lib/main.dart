// lib/main.dart
import 'package:flutter/material.dart';
import 'models/app_config.dart';
import 'services/api_service.dart';
import 'screens/business_login_screen.dart';

// Bu uygulama hangi işletme için?
// PatiVet için: 'pativet'
// Keskin Makas için: 'keskin-makas' gibi.
const String appSlug = 'minekuaför';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Booking App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const AppConfigLoaderScreen(),
    );
  }
}

/// Slug'a göre backend'den app-config alan ve login ekranına yönlendiren ekran
class AppConfigLoaderScreen extends StatefulWidget {
  const AppConfigLoaderScreen({super.key});

  @override
  State<AppConfigLoaderScreen> createState() => _AppConfigLoaderScreenState();
}

class _AppConfigLoaderScreenState extends State<AppConfigLoaderScreen> {
  final ApiService _apiService = ApiService();
  late Future<AppConfig> _futureConfig;

  @override
  void initState() {
    super.initState();
    _futureConfig = _apiService.fetchAppConfig(appSlug);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppConfig>(
      future: _futureConfig,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Hata')),
            body: Center(
              child: Text('Konfigürasyon alınamadı:\n${snapshot.error}'),
            ),
          );
        }

        final config = snapshot.data!;
        // Direkt login ekranına gönderiyoruz
        return BusinessLoginScreen(config: config);
      },
    );
  }
}
