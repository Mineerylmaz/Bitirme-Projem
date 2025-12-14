import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../services/api_service.dart';
import '../theme/business_ui_config.dart';

class CustomerAppointmentsScreen extends StatefulWidget {
  final AppConfig config;
  final String token;

  const CustomerAppointmentsScreen({
    super.key,
    required this.config,
    required this.token,
  });

  @override
  State<CustomerAppointmentsScreen> createState() =>
      _CustomerAppointmentsScreenState();
}

class _CustomerAppointmentsScreenState extends State<CustomerAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late final TabController _tab;

  bool _loadingUpcoming = true;
  bool _loadingPast = true;

  String? _errUpcoming;
  String? _errPast;

  List<Map<String, dynamic>> _upcoming = [];
  List<Map<String, dynamic>> _past = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadUpcoming();
    _loadPast();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadUpcoming() async {
    setState(() {
      _loadingUpcoming = true;
      _errUpcoming = null;
    });
    try {
      final list = await _api.fetchMyAppointments(
        token: widget.token,
        scope: "upcoming",
      );
      if (!mounted) return;
      setState(() => _upcoming = list);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errUpcoming = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _loadingUpcoming = false);
    }
  }

  Future<void> _loadPast() async {
    setState(() {
      _loadingPast = true;
      _errPast = null;
    });
    try {
      final list = await _api.fetchMyAppointments(
        token: widget.token,
        scope: "past",
      );
      if (!mounted) return;
      setState(() => _past = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errPast = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingPast = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ui = getBusinessUiConfig(widget.config);
    final isVet = widget.config.businessTypeCode == "VET";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Randevularım"),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: ui.primaryColor,
          labelColor: ui.primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          tabs: const [Tab(text: "Gelecek"), Tab(text: "Geçmiş")],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildList(
            ui,
            isVet,
            _loadingUpcoming,
            _errUpcoming,
            _upcoming,
            _loadUpcoming,
          ),
          _buildList(ui, isVet, _loadingPast, _errPast, _past, _loadPast),
        ],
      ),
    );
  }

  Widget _buildList(
    BusinessUiConfig ui,
    bool isVet,
    bool loading,
    String? err,
    List<Map<String, dynamic>> data,
    VoidCallback retry,
  ) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (err != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(err, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            TextButton(onPressed: retry, child: const Text("Tekrar dene")),
          ],
        ),
      );
    }
    if (data.isEmpty) {
      return Center(
        child: Text(
          "Kayıt yok.",
          style: TextStyle(color: Colors.grey.shade700),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = data[i];
        final start = (a["start_time"] ?? "").toString();
        final staff = (a["staff_name"] ?? "").toString();
        final staffTitle = (a["staff_title"] ?? "").toString();
        final pet = (a["pet_name"] ?? "").toString();

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
                child: Icon(Icons.event, color: ui.primaryColor),
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
                      "$staff${staffTitle.isEmpty ? "" : " • $staffTitle"}",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    if (isVet)
                      Text(
                        "Hayvan: ${pet.isEmpty ? "-" : pet}",
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
}
