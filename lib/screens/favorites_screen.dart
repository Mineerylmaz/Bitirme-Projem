import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../services/api_service.dart';
import '../theme/business_ui_config.dart';

class FavoritesScreen extends StatefulWidget {
  final AppConfig config;
  final String token;

  const FavoritesScreen({super.key, required this.config, required this.token});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.fetchFavorites(widget.token);
      if (!mounted) return;
      setState(() => _items = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ui = getBusinessUiConfig(widget.config);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(title: const Text("Favorilerim")),
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
                      onPressed: _load,
                      child: const Text("Tekrar dene"),
                    ),
                  ],
                ),
              )
              : _items.isEmpty
              ? Center(
                child: Text(
                  "Favori yok.",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final f = _items[i];
                  final id = (f["id"] ?? 0) as int;
                  final name = (f["staff_name"] ?? "-").toString();
                  final title = (f["staff_title"] ?? "").toString();

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                          color: Colors.black.withOpacity(0.04),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ui.primaryColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.bookmark,
                            color: ui.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (title.isNotEmpty)
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await _api.deleteFavorite(
                              token: widget.token,
                              favoriteId: id,
                            );
                            _load();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
