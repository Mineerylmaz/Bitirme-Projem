import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pet_model.dart';

class CustomerPetFormScreen extends StatefulWidget {
  final String token;

  const CustomerPetFormScreen({super.key, required this.token});

  @override
  State<CustomerPetFormScreen> createState() => _CustomerPetFormScreenState();
}

class _CustomerPetFormScreenState extends State<CustomerPetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _speciesCtrl = TextEditingController(); // Kedi / Köpek vs.
  final _breedCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  DateTime? _birthDate;

  final ApiService _api = ApiService();
  bool _loading = false;
  String? _error;

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 25),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final birthDateStr =
          _birthDate != null
              ? _birthDate!.toIso8601String().substring(0, 10)
              : null;

      await _api.createPet(
        token: widget.token,
        name: _nameCtrl.text.trim(),
        species: _speciesCtrl.text.trim(),
        breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
        color: _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
        birthDate: birthDateStr,
      );

      if (!mounted) return;
      Navigator.pop(context, true); // true = pet eklendi
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
    _speciesCtrl.dispose();
    _breedCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evcil Hayvan Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Hayvan adı',
                  prefixIcon: Icon(Icons.pets),
                ),
                validator:
                    (v) => (v == null || v.isEmpty) ? 'İsim zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _speciesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tür (Kedi, Köpek vb.)',
                  prefixIcon: Icon(Icons.category),
                ),
                validator:
                    (v) => (v == null || v.isEmpty) ? 'Tür zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _breedCtrl,
                decoration: const InputDecoration(
                  labelText: 'Irk (opsiyonel)',
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _colorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Renk (opsiyonel)',
                  prefixIcon: Icon(Icons.color_lens_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _birthDate == null
                          ? 'Doğum tarihi seçilmedi'
                          : 'Doğum tarihi: ${_birthDate!.toLocal().toString().substring(0, 10)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickBirthDate,
                    child: const Text('Tarih Seç'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleSave,
                  child:
                      _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
