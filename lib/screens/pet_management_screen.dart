// lib/screens/pet_management_screen.dart
import 'package:flutter/material.dart';

import '../models/app_config.dart';
import '../models/pet_model.dart';
import '../services/api_service.dart';
import '../theme/business_ui_config.dart';

class PetManagementScreen extends StatefulWidget {
  final AppConfig config;
  final String token;

  const PetManagementScreen({
    super.key,
    required this.config,
    required this.token,
  });

  @override
  State<PetManagementScreen> createState() => _PetManagementScreenState();
}

class _PetManagementScreenState extends State<PetManagementScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  List<PetModel> _pets = [];

  final _nameCtrl = TextEditingController();
  final _speciesCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final pets = await _api.fetchMyPets(widget.token);
      setState(() {
        _pets = pets;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 1, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _openAddPetDialog() async {
    _nameCtrl.clear();
    _speciesCtrl.clear();
    _breedCtrl.clear();
    _colorCtrl.clear();
    _birthDate = null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final ui = getBusinessUiConfig(widget.config);

        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const Text(
                  "Yeni Evcil Hayvan Ekle",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Adı",
                    prefixIcon: const Icon(Icons.pets),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _speciesCtrl,
                  decoration: InputDecoration(
                    labelText: "Tür (örn. Köpek, Kedi)",
                    prefixIcon: const Icon(Icons.category),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _breedCtrl,
                  decoration: InputDecoration(
                    labelText: "Irk (opsiyonel)",
                    prefixIcon: const Icon(Icons.badge),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _colorCtrl,
                  decoration: InputDecoration(
                    labelText: "Renk (opsiyonel)",
                    prefixIcon: const Icon(Icons.color_lens),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                InkWell(
                  onTap: _pickBirthDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Doğum Tarihi (opsiyonel)",
                      prefixIcon: const Icon(Icons.cake),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    child: Text(
                      _birthDate == null
                          ? "Seçilmedi"
                          : "${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}",
                      style: TextStyle(
                        color:
                            _birthDate == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _saving
                            ? null
                            : () async {
                              if (_nameCtrl.text.trim().isEmpty ||
                                  _speciesCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Lütfen en az ad ve tür alanlarını doldurun.",
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _saving = true;
                              });

                              try {
                                final birthDateStr =
                                    _birthDate == null
                                        ? null
                                        : "${_birthDate!.year.toString().padLeft(4, '0')}-"
                                            "${_birthDate!.month.toString().padLeft(2, '0')}-"
                                            "${_birthDate!.day.toString().padLeft(2, '0')}";

                                await _api.createPet(
                                  token: widget.token,
                                  name: _nameCtrl.text.trim(),
                                  species: _speciesCtrl.text.trim(),
                                  breed:
                                      _breedCtrl.text.trim().isEmpty
                                          ? null
                                          : _breedCtrl.text.trim(),
                                  color:
                                      _colorCtrl.text.trim().isEmpty
                                          ? null
                                          : _colorCtrl.text.trim(),
                                  birthDate: birthDateStr,
                                );

                                if (!mounted) return;

                                Navigator.pop(context); // bottom sheet kapat
                                await _loadPets(); // listeyi yenile
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Kaydedilemedi: $e")),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _saving = false;
                                  });
                                }
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ui.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child:
                        _saving
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Kaydet",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _speciesCtrl.dispose();
    _breedCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ui = getBusinessUiConfig(widget.config);

    return Scaffold(
      appBar: AppBar(title: const Text("Evcil Hayvanlarım")),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text("Hata: $_error"))
              : Column(
                children: [
                  Expanded(
                    child:
                        _pets.isEmpty
                            ? const Center(
                              child: Text(
                                "Henüz kayıtlı evcil hayvanın yok.\nAşağıdan ekleyebilirsin.",
                                textAlign: TextAlign.center,
                              ),
                            )
                            : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _pets.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final p = _pets[index];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                        color: Colors.black.withOpacity(0.03),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: ui.primaryColor.withOpacity(
                                            0.12,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.pets),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              [
                                                p.species,
                                                if (p.breed != null &&
                                                    p.breed!.isNotEmpty)
                                                  p.breed,
                                              ].join(" • "),
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
                                );
                              },
                            ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _openAddPetDialog,
                        icon: const Icon(Icons.add),
                        label: const Text(
                          "Yeni Evcil Hayvan Ekle",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ui.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
