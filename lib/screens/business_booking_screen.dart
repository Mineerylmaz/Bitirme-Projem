import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../models/auth_user.dart';
import '../models/staff_model.dart';
import '../models/pet_model.dart';
import '../services/api_service.dart';

class BusinessBookingScreen extends StatefulWidget {
  final AppConfig config;
  final AuthUser currentUser;
  final String token;

  const BusinessBookingScreen({
    super.key,
    required this.config,
    required this.currentUser,
    required this.token,
  });

  @override
  State<BusinessBookingScreen> createState() => _BusinessBookingScreenState();
}

class _BusinessBookingScreenState extends State<BusinessBookingScreen> {
  final ApiService _api = ApiService();

  List<_ServiceOption> _services = [];
  List<StaffModel> _staffList = [];
  List<PetModel> _pets = [];

  _ServiceOption? _selectedService;
  StaffModel? _selectedStaff;
  PetModel? _selectedPet;

  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  bool _loading = true;
  String? _error;

  final List<String> _timeSlots = const [
    "09:00",
    "10:00",
    "11:00",
    "13:00",
    "14:00",
    "15:00",
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // İşletme tipine göre servisleri local’de belirliyoruz (şimdilik)
      final services = _buildServicesForBusiness(
        widget.config.businessTypeCode,
      );

      // Personel listesini backend’den çek
      final staff = await _api.fetchStaffByBusiness(widget.config.businessId);

      // Kullanıcının evcil hayvanlarını backend’den çek
      final pets = await _api.fetchMyPets(widget.token);

      setState(() {
        _services = services;
        _staffList = staff;
        _pets = pets;

        if (_services.isNotEmpty) _selectedService = _services.first;
        if (_staffList.isNotEmpty) _selectedStaff = _staffList.first;
        if (_pets.isNotEmpty) _selectedPet = _pets.first;

        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ---- İşletme tipine göre servisler ----
  List<_ServiceOption> _buildServicesForBusiness(String type) {
    switch (type) {
      case 'VET':
        return [
          _ServiceOption("GENEL", "Genel Muayene", Icons.health_and_safety),
          _ServiceOption("VACCINE", "Aşılama", Icons.vaccines),
          _ServiceOption("GROOM", "Tıraş / Bakım", Icons.cut),
        ];
      case 'BARBER':
        return [
          _ServiceOption("HAIR", "Saç Kesimi", Icons.content_cut),
          _ServiceOption(
            "BEARD",
            "Sakal Tıraşı",
            Icons.face_retouching_natural,
          ),
          _ServiceOption("PACKAGE", "Bakım Paketi", Icons.spa),
        ];
      case 'PHYSIO':
        return [
          _ServiceOption(
            "SESSION",
            "Fizyoterapi Seansı",
            Icons.accessibility_new,
          ),
          _ServiceOption("CHECK", "Kontrol Randevusu", Icons.medical_services),
        ];
      default:
        return [
          _ServiceOption("GENERIC", "Hizmet", Icons.miscellaneous_services),
        ];
    }
  }

  String get _bookingTitle {
    switch (widget.config.businessTypeCode) {
      case 'VET':
        return "Randevu Oluştur";
      case 'BARBER':
        return "Randevu Al";
      case 'PHYSIO':
        return "Seans Planla";
      default:
        return "Randevu";
    }
  }

  String get _serviceQuestion {
    switch (widget.config.businessTypeCode) {
      case 'VET':
        return "Hangi hizmeti istiyorsunuz?";
      case 'BARBER':
        return "Nasıl bir hizmet istiyorsunuz?";
      case 'PHYSIO':
        return "Hangi seansı planlıyorsunuz?";
      default:
        return "Hangi hizmeti istiyorsunuz?";
    }
  }

  String get _staffLabel {
    switch (widget.config.businessTypeCode) {
      case 'VET':
        return "Veteriner Seçin";
      case 'BARBER':
        return "Berber Seçin";
      case 'PHYSIO':
        return "Fizyoterapist Seçin";
      default:
        return "Uzman Seçin";
    }
  }

  String get _confirmText {
    switch (widget.config.businessTypeCode) {
      case 'VET':
        return "Randevuyu Onayla";
      case 'BARBER':
        return "Randevuyu Onayla";
      case 'PHYSIO':
        return "Seansı Onayla";
      default:
        return "Onayla";
    }
  }

  Future<void> _handleConfirm() async {
    if (_selectedService == null ||
        _selectedTime == null ||
        _selectedStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm seçimleri tamamlayın")),
      );
      return;
    }

    try {
      // Saat stringini DateTime'a çevir
      final parts = _selectedTime!.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final start = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      );

      // Şimdilik her hizmet 30 dk varsayıyoruz
      final end = start.add(const Duration(minutes: 30));

      await _api.createAppointment(
        token: widget.token,
        customerId: widget.currentUser.id,
        staffId: _selectedStaff!.id,
        // TODO: services tablosuna geçtiğimizde buraya gerçek serviceId gelecek
        serviceId: 1,
        petId: _selectedPet?.id,
        startTime: start,
        endTime: end,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Başarılı"),
              content: const Text("Randevunuz oluşturuldu."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tamam"),
                ),
              ],
            ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
        Colors.blue; // İleride config veya ui theme ile bağlanır.

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_bookingTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            // ---- Randevu Sahibi + Pet seçimi ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, child: Icon(Icons.person)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Randevu Sahibi",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.currentUser.email,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_pets.isNotEmpty)
                          DropdownButton<PetModel>(
                            value: _selectedPet,
                            isExpanded: true,
                            items:
                                _pets.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      p.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedPet = val;
                              });
                            },
                          )
                        else
                          const Text(
                            "Kayıtlı evcil hayvanınız bulunmuyor.",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---- Hizmet seçimi ----
            Text(
              _serviceQuestion,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _services.map((s) {
                      final selected = _selectedService == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                s.icon,
                                size: 18,
                                color: selected ? Colors.white : Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Text(s.name),
                            ],
                          ),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedService = s;
                            });
                          },
                          selectedColor: themeColor,
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ---- Tarih & saat ----
            const Text(
              "Tarih ve Saat Seçin",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(8),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                onDateChanged: (d) {
                  setState(() {
                    _selectedDate = d;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _timeSlots.map((t) {
                    final selected = _selectedTime == t;
                    return ChoiceChip(
                      label: Text(t),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedTime = t;
                        });
                      },
                      selectedColor: themeColor,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 24),

            // ---- Personel seçimi ----
            Text(
              _staffLabel,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            if (_staffList.isEmpty)
              const Text(
                "Bu işletmeye ait kayıtlı personel bulunmuyor.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              )
            else
              Column(
                children:
                    _staffList.map((s) {
                      final selected = _selectedStaff == s;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStaff = s;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                                selected
                                    ? themeColor.withOpacity(0.08)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  selected ? themeColor : Colors.grey.shade300,
                              width: selected ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                child: Text(
                                  s.name.isNotEmpty ? s.name[0] : "?",
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (s.title != null && s.title!.isNotEmpty)
                                    Text(
                                      s.title!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),

            const SizedBox(height: 24),

            // ---- Onay butonu ----
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _confirmText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---- İçeride kullanılan basit servis modeli ----

class _ServiceOption {
  final String code;
  final String name;
  final IconData icon;

  _ServiceOption(this.code, this.name, this.icon);
}
