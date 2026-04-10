import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_cardiologue/models/patient.dart';

class ApiService {
  // Remplacer par l'adresse IP de votre serveur (ex: http://192.168.1.50:5000)
  // 'http://10.0.2.2:5000' est utilisé pour l'émulateur Android vers le localhost
  static const String baseUrl = 'http://10.0.2.2:5000'; 

  // --- AUTHENTIFICATION DOCTEUR ---

  static Future<Map<String, dynamic>> signUpDoctor({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/doctor/register'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Inscription réussie'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Échec de l\'inscription'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion : $e'};
    }
  }

  static Future<Map<String, dynamic>> loginDoctor({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/doctor/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true, 
          'name': data['user']?['name'] ?? 'Docteur',
          'token': data['token']
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Échec de la connexion'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau : $e'};
    }
  }

  // --- PATIENTS ---

  static Future<List<Patient>> fetchPatients() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Patient.fromJson(json)).toList();
      } else {
        throw Exception('Échec de la récupération des patients');
      }
    } catch (e) {
      print('Erreur ApiService: $e');
      return []; 
    }
  }

  static Future<List<double>> fetchEcgData(String patientId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ecg/$patientId'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return List<double>.from(data['ecg_values'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Erreur ECG ApiService: $e');
      return [];
    }
  }
}

