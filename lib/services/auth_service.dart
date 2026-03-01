import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = "http://localhost:60020/api"; 
  final Dio _dio = Dio();

  // LOGIN: Solo se encarga de la petición y guardar el token
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post("$_baseUrl/Auth/login", data: {
        "email": email,
        "password": password,
      });
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', response.data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // LOGOUT: Solo se encarga de borrar el token de la memoria
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // REVISAR SESIÓN: Útil para saber si el usuario ya estaba logueado al abrir la app
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('jwt_token');
  }

  // REGISTRO (Asegúrate que esté DENTRO de la clase)
  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post("$_baseUrl/Auth/register", data: userData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error en registro: $e");
      return false;
    }
  }

  // En tu servicio
Future<String?> generatePairingCode() async {
  // Lógica para llamar a tu API y obtener el string del código
  final response = await _dio.get("$_baseUrl/Couple/generate-code");
  return response.data['code']; 
}

Future<bool> linkWithPartner(String code) async {
  // Lógica para enviar el código e intentar el vínculo
  final response = await _dio.post("$_baseUrl/Couple/join", data: {"code": code});
  return response.statusCode == 200;
}

  // LISTADOS PARA REGISTRO
  Future<Map<String, dynamic>> getRegistrationData() async {
    try {
      // Ajusta la ruta según tu nuevo ListingsController
      final response = await _dio.get("$_baseUrl/Listings/registration-data");
      return response.data;
    } catch (e) {
      print("Error obteniendo listados: $e");
      return {};
    }
  }
} 