import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskService {
  // Cambia localhost por tu IP si pruebas en un celular físico
  final String _baseUrl = "http://localhost:60020/api";
  final Dio _dio = Dio();

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return Options(headers: {"Authorization": "Bearer $token"});
  }

  Future<List<TaskModel>> getPendingTasks() async {
  try {
    final options = await _getAuthOptions();
    final response = await _dio.get("$_baseUrl/Task/pending", options: options);
    
    // Convertimos la lista de mapas JSON en una lista de objetos TaskModel
    return (response.data as List)
        .map((taskJson) => TaskModel.fromJson(taskJson))
        .toList();
  } catch (e) {
    return [];
  }
}

  Future<Map<String, dynamic>> getSummary() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get("$_baseUrl/Task/summary", options: options);
      return response.data;
    } catch (e) {
      return {"totalPoints": 0, "completedTasks": 0, "pendingTasks": 0};
    }
  }

  Future<Map<String, dynamic>> getCoupleStatus() async {
  try {
    final options = await _getAuthOptions();
    final response = await _dio.get("http://localhost:60020/api/Couple/status", options: options);
    return response.data;
  } catch (e) {
    return {};
  }
}

// Dentro de tu archivo task_service.dart
Future<String?> generatePairingCode() async {
  try {
    // 1. Obtener el token guardado
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    // 2. Hacer la petición con el header de Authorization
    final response = await _dio.post(
      "$_baseUrl/Couple/generate-code", // Asegúrate de que esta ruta coincida con tu [HttpGet] en .NET
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    // 3. Verificar que el servidor respondió JSON
    if (response.statusCode == 200) {
      // Si tu backend devuelve solo el string, usa: return response.data.toString();
      // Si devuelve un objeto { "code": "ABC123" }, usa:
      return response.data['code']; 
    }
    return null;
  } catch (e) {
    print("Error al generar código: $e");
    return null;
  }
}

Future<bool> linkWithPartner(String code) async {
  try {
    // 1. Necesitamos el Token para el 401 y el ID para la URL
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    // NOTA: Aquí deberías tener una forma de obtener el ID del usuario actual.
    // Si no lo tienes a mano, podrías guardarlo en SharedPreferences al hacer login.
    final String? myId = prefs.getString('user_id'); 

    final response = await _dio.post(
      "$_baseUrl/Couple/join", 
      queryParameters: {
        "userId": myId,           // <--- Esto agregará &userId=... a la URL
        "pairingCode": code.trim().toUpperCase()
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token', // <--- Esto soluciona el 401
        },
      ),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print("Error al vincular: $e");
    return false;
  }
}
}