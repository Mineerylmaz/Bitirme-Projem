import 'package:flutter/material.dart';

import '../models/app_config.dart';
import '../models/auth_user.dart';
import '../models/staff_model.dart';
import '../services/api_service.dart';
import '../theme/business_ui_config.dart';

class AdminHomeScreen extends StatefulWidget {
  final AppConfig config;
  final AuthUser user;
  final String token;

  const AdminHomeScreen({
    super.key,
    required this.config,
    required this.user,
    required this.token,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();

  late final TabController _tab;

  bool _loadingStaff = true;
  bool _loadingAppointments = true;
  bool _loadingCustomers = true;

  String? _staffError;
  String? _apptError;
  String? _custError;

  List<StaffModel> _staff = [];
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _customers = [];

  bool _creating = false;

  // --- dinamik label’lar
  String get _staffLabel {
    switch (widget.config.businessTypeCode) {
      case 'VET':
        return 'Veteriner';
      case 'BARBER':
        return 'Kuaför';
      case 'PHYSIO':
        return 'Fizyoterapist';
      default:
        return 'Uzman';
    }
  }

  String get _customerLabel {
    switch (widget.config.businessTypeCode) {
      case 'PHYSIO':
        return 'Danışan';
      default:
        return 'Müşteri';
    }
  }

  String get _petLabel {
    switch (widget.config.businessTypeCode) {
      case 'VET':
        return 'Hayvan(lar)';
      default:
        return 'Not';
    }
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);

    _loadStaff();
    _loadAppointments();
    _loadCustomersGrid();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    setState(() {
      _loadingStaff = true;
      _staffError = null;
    });

    try {
      final list = await _api.fetchMyStaff(widget.token);
      if (!mounted) return;
      setState(() => _staff = list);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _staffError = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loadingStaff = false);
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loadingAppointments = true;
      _apptError = null;
    });

    try {
      final list = await _api.fetchBusinessAppointments(widget.token);
      if (!mounted) return;
      setState(() => _appointments = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _apptError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loadingAppointments = false);
    }
  }

  Future<void> _loadCustomersGrid() async {
    setState(() {
      _loadingCustomers = true;
      _custError = null;
    });

    try {
      final list = await _api.fetchBusinessCustomersGrid(widget.token);
      if (!mounted) return;
      setState(() => _customers = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _custError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loadingCustomers = false);
    }
  }

  Future<void> _showCreateStaffDialog() async {
    final nameCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final photoCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) {
        final ui = getBusinessUiConfig(widget.config);
        return AlertDialog(
          title: Text('Yeni $_staffLabel Ekle'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Ad Soyad'),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Zorunlu alan'
                                  : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Ünvan / Alan',
                        hintText:
                            widget.config.businessTypeCode == 'VET'
                                ? 'örn: Küçük Hayvan Uzmanı'
                                : 'örn: Saç & Sakal / Ortopedik Rehab',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: photoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Foto URL (şimdilik)',
                        hintText: 'https://...jpg',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Telefon'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'E-posta'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: bioCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Kısa Açıklama (bio)',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Not: Foto yüklemeyi sonra dosya upload ile ekleriz.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _creating ? null : () => Navigator.pop(context),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              style: ElevatedButton.styleFrom(backgroundColor: ui.primaryColor),
              onPressed:
                  _creating
                      ? null
                      : () async {
                        if (!formKey.currentState!.validate()) return;

                        setState(() => _creating = true);
                        try {
                          final newStaff = await _api.createStaff(
                            token: widget.token,
                            name: nameCtrl.text.trim(),
                            title:
                                titleCtrl.text.trim().isEmpty
                                    ? null
                                    : titleCtrl.text.trim(),
                            photoUrl:
                                photoCtrl.text.trim().isEmpty
                                    ? null
                                    : photoCtrl.text.trim(),
                            phone:
                                phoneCtrl.text.trim().isEmpty
                                    ? null
                                    : phoneCtrl.text.trim(),
                            email:
                                emailCtrl.text.trim().isEmpty
                                    ? null
                                    : emailCtrl.text.trim(),
                            bio:
                                bioCtrl.text.trim().isEmpty
                                    ? null
                                    : bioCtrl.text.trim(),
                          );

                          if (!mounted) return;
                          setState(() => _staff = [..._staff, newStaff]);
                          Navigator.pop(context);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Eklenemedi: ${e.toString().replaceFirst('Exception: ', '')}',
                              ),
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _creating = false);
                        }
                      },
              label:
                  _creating
                      ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  // ---- küçük dashboard kartı
  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
      appBar: AppBar(
        title: Text('${widget.config.businessName} • Admin'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: ui.primaryColor,
          labelColor: ui.primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          tabs: const [
            Tab(text: 'Personel'),
            Tab(text: 'Randevular'),
            Tab(text: 'Müşteriler'),
          ],
        ),
      ),
      floatingActionButton:
          _tab.index == 0
              ? FloatingActionButton.extended(
                backgroundColor: ui.primaryColor,
                onPressed: _showCreateStaffDialog,
                icon: const Icon(Icons.person_add),
                label: Text('Yeni $_staffLabel'),
              )
              : null,
      body: SafeArea(
        child: Column(
          children: [
            // --- üst dashboard
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş geldiniz, ${widget.user.email}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          icon: Icons.groups,
                          title: '$_staffLabel sayısı',
                          value: _loadingStaff ? '...' : '${_staff.length}',
                          color: ui.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          icon: Icons.event,
                          title: 'Randevu',
                          value:
                              _loadingAppointments
                                  ? '...'
                                  : '${_appointments.length}',
                          color: ui.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- tab içerikleri
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  // 1) PERSONEL
                  _buildStaffTab(ui),

                  // 2) RANDEVULAR
                  _buildAppointmentsTab(ui),

                  // 3) MÜŞTERİ GRID
                  _buildCustomersTab(ui),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffTab(BusinessUiConfig ui) {
    if (_loadingStaff) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_staffError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_staffError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            TextButton(onPressed: _loadStaff, child: const Text('Tekrar dene')),
          ],
        ),
      );
    }
    if (_staff.isEmpty) {
      return Center(
        child: Text(
          'Henüz personel eklenmemiş.\nSağ alttan "Yeni $_staffLabel" ekleyin.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _staff.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = _staff[i];
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
              CircleAvatar(
                radius: 26,
                backgroundColor: ui.primaryColor.withOpacity(0.12),
                backgroundImage:
                    (s.photoUrl != null && s.photoUrl!.isNotEmpty)
                        ? NetworkImage(s.photoUrl!)
                        : null,
                child:
                    (s.photoUrl == null || s.photoUrl!.isEmpty)
                        ? Text(
                          (s.name.isNotEmpty ? s.name[0] : '?').toUpperCase(),
                          style: TextStyle(
                            color: ui.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (s.title != null && s.title!.trim().isNotEmpty)
                      Text(
                        s.title!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    if (s.phone != null && s.phone!.trim().isNotEmpty)
                      Text(
                        '📞 ${s.phone}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (s.email != null && s.email!.trim().isNotEmpty)
                      Text(
                        '✉️ ${s.email}',
                        style: const TextStyle(
                          fontSize: 12,
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
    );
  }

  Widget _buildAppointmentsTab(BusinessUiConfig ui) {
    if (_loadingAppointments)
      return const Center(child: CircularProgressIndicator());
    if (_apptError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_apptError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _loadAppointments,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      );
    }
    if (_appointments.isEmpty) {
      return Center(
        child: Text(
          'Henüz randevu yok.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = _appointments[i];
        final start = (a['start_time'] ?? '').toString();
        final staff = (a['staff_name'] ?? '').toString();
        final customer = (a['customer_email'] ?? '').toString();
        final pet = (a['pet_name'] ?? '').toString();

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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ui.primaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.event_available, color: ui.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      start,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_staffLabel: $staff',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      '$_customerLabel: $customer',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    if (widget.config.businessTypeCode == 'VET')
                      Text(
                        '$_petLabel: ${pet.isEmpty ? '-' : pet}',
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
    );
  }

  Widget _buildCustomersTab(BusinessUiConfig ui) {
    if (_loadingCustomers)
      return const Center(child: CircularProgressIndicator());
    if (_custError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_custError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _loadCustomersGrid,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      );
    }
    if (_customers.isEmpty) {
      return Center(
        child: Text(
          'Henüz $_customerLabel yok.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      );
    }

    // Panel hissi: DataTable
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
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
        child: DataTable(
          headingTextStyle: const TextStyle(fontWeight: FontWeight.w800),
          columns: [
            DataColumn(label: Text('$_customerLabel')),
            DataColumn(
              label: Text(
                widget.config.businessTypeCode == 'VET' ? _petLabel : 'Not',
              ),
            ),
            const DataColumn(label: Text('Randevu')),
          ],
          rows:
              _customers.map((c) {
                final email = (c['customer_email'] ?? '').toString();
                final petNames = (c['pet_names'] ?? '').toString();
                final apptCount = (c['appointment_count'] ?? 0).toString();

                return DataRow(
                  cells: [
                    DataCell(Text(email)),
                    DataCell(
                      Text(
                        widget.config.businessTypeCode == 'VET'
                            ? (petNames.isEmpty ? '-' : petNames)
                            : '-',
                      ),
                    ),
                    DataCell(Text(apptCount)),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}
