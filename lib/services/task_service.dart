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
    final response = await _dio.get("$_baseUrl/Tasks/pending", options: options);
    
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
      final response = await _dio.get("$_baseUrl/Tasks/summary", options: options);
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      print("Error en getSummary: $e");
      return {"totalPoints": 0, "completedTasks": 0, "pendingTasks": 0};
    }
  }

  // Dentro de la clase TaskService

// 1. Obtener los deseos/pedidos creados por la pareja

Future<List<TaskModel>> getPartnerRequests() async {
  try {
    final options = await _getAuthOptions();
    final response = await _dio.get(
      "$_baseUrl/Tasks/received-requests", 
      options: options,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = response.data; 
      // Aquí es donde ocurría el fallo si el fromJson no era tolerante
      return body.map((item) => TaskModel.fromJson(item)).toList();
    }
    return [];
  } catch (e, stacktrace) {
    // Te sugiero imprimir el stacktrace para cazar rápido estos errores de mapeo
    print("Error parseando deseos: $e");
    print(stacktrace);
    return [];
  }
}

// Future<List<TaskModel>> getPartnerRequests() async {
//   try {
//     final options = await _getAuthOptions();
//     final response = await _dio.get(
//       "$_baseUrl/Tasks/partner-requests",
//       options: options,
//     );

//     if (response.statusCode == 200) {
//       // En Dio, response.data ya es una Lista/Mapa, no un String
//       final List<dynamic> data = response.data; 
//       return data.map((item) => TaskModel.fromJson(item)).toList();
//     }
//     return [];
//   } catch (e) {
//     print("Error en getPartnerRequests: $e");
//     return [];
//   }
// }
// 2. Crear un nuevo deseo (Request)
  Future<bool> createGoalRequest(String title, DateTime targetDate) async {
  try {
    // 1. Obtenemos las opciones que ya incluyen el Auth (JWT)
    final options = await _getAuthOptions(); 
    
    // 2. Realizamos el POST al endpoint exacto que definiste
    final response = await _dio.post(
      "$_baseUrl/Tasks/create-wish", // Endpoint según tu especificación
      data: {
        "title": title,
        "description": "Solicitud para el ${targetDate.day}/${targetDate.month}/${targetDate.year}",
        // Si tu API usa otros nombres de campos, asegúrate de mapearlos aquí
      },
      options: options, // Aquí va el Bearer Token
    );

    // 3. Verificamos éxito (200 OK o 201 Created)
    return response.statusCode == 200 || response.statusCode == 201;
  } on DioException catch (e) {
    // Manejo de errores específico de Dio
    print("Error creando deseo: ${e.response?.statusCode} - ${e.response?.data}");
    return false;
  } catch (e) {
    print("Error inesperado: $e");
    return false;
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

Future<bool> createTask(Map<String, dynamic> taskData) async {
  try {
    final options = await _getAuthOptions();
    
    // El mapa que enviamos al API debe ser limpio
    final Map<String, dynamic> payload = {
      "title": taskData['title'],
      "description": taskData['description'] ?? "",
      "points": taskData['points'] ?? 0,
      "assignedToUserId": taskData['assignedToUserId'],
      "dueDate": taskData['dueDate'], // <-- QUITAMOS el .toIso8601String() aquí
    };

    print("Cuerpo de la petición: $payload"); // Para confirmar en consola

    final response = await _dio.post(
      "$_baseUrl/Tasks/create-task",
      data: payload,
      options: options,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  } on DioException catch (e) {
    print("Error Dio: ${e.response?.statusCode} - ${e.response?.data}");
    return false;
  } catch (e) {
    print("Error lógico en Flutter: $e");
    return false;
  }
}
}