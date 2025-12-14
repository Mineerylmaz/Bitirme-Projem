import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/app_config.dart';
import '../models/login_response.dart';
import '../models/staff_model.dart';
import '../models/pet_model.dart';

class ApiService {
  // senin base url’in
  static const String baseUrl = 'http://localhost:3000';

  // ---------------- APP CONFIG ----------------
  Future<AppConfig> fetchAppConfig(String slug) async {
    final uri = Uri.parse('$baseUrl/api/public/app-config?slug=$slug');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('App config alınamadı: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return AppConfig.fromJson(data);
  }

  // ---------------- AUTH ----------------
  Future<LoginResponse> login({
    required String email,
    required String password,
    required int businessId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'businessId': businessId,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Giriş başarısız: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return LoginResponse.fromJson(data);
  }

  Future<void> registerCustomer({
    required String email,
    required String password,
    required int businessId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/register');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'businessId': businessId,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('Kayıt başarısız: ${res.body}');
    }
  }

  // ---------------- STAFF ----------------
  Future<List<StaffModel>> fetchStaffByBusiness(int businessId) async {
    final uri = Uri.parse('$baseUrl/api/booking/staff?businessId=$businessId');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Personel listesi alınamadı: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => StaffModel.fromJson(e)).toList();
  }

  // ---------------- PETS ----------------

  /// Eğer backend'in hâlâ `/api/pets?ownerId=...` şeklinde çalışıyorsa bunu kullan.

  /// Eğer backend'i JWT ile auth'lu `/api/pets` yaparsan bunu kullanırsın.
  Future<List<PetModel>> fetchMyPets(String token) async {
    final uri = Uri.parse('$baseUrl/api/pets');

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Pet listesi alınamadı: ${res.body}');
    }

    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => PetModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // models için: staff_model.dart içine photoUrl/phone/email/bio alanlarını eklemen lazım.

  Future<List<StaffModel>> fetchMyStaff(String token) async {
    final uri = Uri.parse('$baseUrl/api/booking/my-staff');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Personel listesi alınamadı: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => StaffModel.fromJson(e)).toList();
  }

  Future<StaffModel> createStaff({
    required String token,
    required String name,
    String? title,
    String? photoUrl,
    String? phone,
    String? email,
    String? bio,
  }) async {
    final uri = Uri.parse('$baseUrl/api/booking/staff');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'title': title,
        'photoUrl': photoUrl,
        'phone': phone,
        'email': email,
        'bio': bio,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('Personel eklenemedi: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return StaffModel.fromJson(data);
  }

  // ---- Randevular
  Future<List<Map<String, dynamic>>> fetchBusinessAppointments(
    String token,
  ) async {
    final uri = Uri.parse('$baseUrl/api/booking/my-appointments');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Randevular alınamadı: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchMyAppointments({
    required String token,
    required String scope, // upcoming | past
  }) async {
    final uri = Uri.parse('$baseUrl/api/me/appointments?scope=$scope');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Randevular alınamadı: ${res.body}');
    }
    return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> fetchMe(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception("Profil alınamadı: ${res.statusCode} ${res.body}");
  }

  Future<List<Map<String, dynamic>>> fetchFavorites(String token) async {
    final uri = Uri.parse('$baseUrl/api/me/favorites');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Favoriler alınamadı: ${res.body}');
    }
    return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
  }

  Future<void> deleteFavorite({
    required String token,
    required int favoriteId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/me/favorites/$favoriteId');
    final res = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Favori silinemedi: ${res.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBusinessCustomersGrid(
    String token,
  ) async {
    final uri = Uri.parse('$baseUrl/api/booking/my-customers-grid');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Müşteriler alınamadı: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<PetModel> createPet({
    required String token,
    required String name,
    required String species,
    String? breed,
    String? color,
    String? birthDate, // "YYYY-MM-DD"
  }) async {
    final uri = Uri.parse('$baseUrl/api/pets');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'species': species,
        'breed': breed,
        'color': color,
        'birthDate': birthDate,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('Pet kaydedilemedi: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return PetModel.fromJson(data);
  }

  // ---------------- APPOINTMENTS ----------------
  Future<void> createAppointment({
    required String token,
    required int customerId,
    required int staffId,
    required int serviceId,
    int? petId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final uri = Uri.parse('$baseUrl/api/booking/appointments');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'customerId': customerId,
        'staffId': staffId,
        'serviceId': serviceId,
        'petId': petId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('Randevu oluşturulamadı: ${res.body}');
    }
  }
}
