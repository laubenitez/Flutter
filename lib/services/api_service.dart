
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl =
      'https://laubenitez.pythonanywhere.com';

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/api-token-auth/');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'username': email.trim(),
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception('El servidor no devolvió el token.');
      }

      await _storage.write(
        key: 'auth_token',
        value: token.toString(),
      );

      return true;
    }

    if (response.statusCode == 400 ||
        response.statusCode == 401) {
      return false;
    }

    throw Exception(
      'Error del servidor: ${response.statusCode}',
    );
  }

  Future<String?> getToken() {
    return _storage.read(key: 'auth_token');
  }

  Future<void> logout() {
    return _storage.delete(key: 'auth_token');
  }

  Future<List<dynamic>> obtenerServicios() async {
  final token = await getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Tu sesión ha expirado. Inicia sesión nuevamente.');
  }

  final url = Uri.parse('$baseUrl/v1/servicios/');

  final response = await http.get(
    url,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Token $token',
    },
  ).timeout(const Duration(seconds: 20));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // Admite respuestas paginadas de Django REST Framework
    // y respuestas que sean directamente una lista.
    if (data is List) {
      return data;
    }

    if (data is Map && data['results'] is List) {
      return data['results'] as List<dynamic>;
    }

    throw Exception('El formato de servicios recibido no es válido.');
  }

  if (response.statusCode == 401 || response.statusCode == 403) {
    throw Exception('No tienes autorización para consultar los servicios.');
  }

  throw Exception(
    'No se pudieron cargar los servicios (${response.statusCode}).',
  );
}

  Future<List<dynamic>> _obtenerLista(
    String endpoint,
    String recurso,
  ) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Tu sesión ha expirado. Inicia sesión nuevamente.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/v1/$endpoint/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $token',
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) return data;

      if (data is Map && data['results'] is List) {
        return data['results'] as List<dynamic>;
      }

      throw Exception('La respuesta de $recurso no tiene un formato válido.');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception(
        'No tienes autorización para consultar $recurso '
        '(HTTP ${response.statusCode}).',
      );
    }

    throw Exception(
      'Error al consultar $recurso: HTTP ${response.statusCode}.',
    );
  }

  Future<List<dynamic>> obtenerCitas() {
    return _obtenerLista('citas', 'las citas');
  }

  Future<List<dynamic>> obtenerManicuristas() async {
    final lista = await _obtenerLista(
      'manicuristas',
      'las manicuristas',
    );

    return lista.where((item) {
      if (item is! Map) return false;

      return item['estado']?.toString().toLowerCase() == 'activa';
    }).toList();
  }

  Future<Map<String, dynamic>> crearCita({
    required int manicuristaId,
    required int servicioId,
    required DateTime fecha,
    required String hora,
    required int total,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Tu sesión ha expirado. Inicia sesión nuevamente.');
    }

    final fechaTexto =
        '${fecha.year.toString().padLeft(4, '0')}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';

    final response = await http.post(
      Uri.parse('$baseUrl/v1/citas/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode({
        'manicurista': manicuristaId,
        'servicios': servicioId,
        'fecha': fechaTexto,
        'hora': hora,
        'total': total,
      }),
    ).timeout(const Duration(seconds: 20));

    final dynamic data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception('El servidor devolvió una respuesta inesperada.');
    }

    if (response.statusCode == 400) {
      throw Exception('No se pudo registrar la cita: $data');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('No tienes autorización para crear la cita.');
    }

    throw Exception(
      'Error al crear la cita: HTTP ${response.statusCode}. $data',
    );
  }


Future<List<dynamic>> obtenerResenas() {
  return _obtenerLista('resenas', 'tus reseñas');
}

Future<Map<String, dynamic>> crearResena({
  required int citaId,
  required int calificacion,
  String? comentario,
}) async {
  final token = await getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Tu sesión ha expirado. Inicia sesión nuevamente.');
  }

  final response = await http.post(
    Uri.parse('$baseUrl/v1/resenas/'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Token $token',
    },
    body: jsonEncode({
      'cita': citaId,
      'calificacion': calificacion,
      'comentario': comentario?.trim() ?? '',
    }),
  ).timeout(const Duration(seconds: 20));

  dynamic data;
  try {
    data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};
  } catch (_) {
    throw Exception(
      'El servidor devolvió una respuesta inesperada '
      '(HTTP ${response.statusCode}).',
    );
  }

  if (response.statusCode == 200 || response.statusCode == 201) {
    return Map<String, dynamic>.from(data as Map);
  }

  throw Exception(
    'No se pudo guardar la reseña '
    '(HTTP ${response.statusCode}): $data',
  );
}


  Future<Map<String, dynamic>> obtenerMiPerfil() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Tu sesión ha expirado. Inicia sesión nuevamente.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/v1/clientes/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Token $token',
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);

      List<dynamic> clientes;

      if (data is List) {
        clientes = data;
      } else if (data is Map && data['results'] is List) {
        clientes = data['results'] as List<dynamic>;
      } else {
        throw Exception('El formato del perfil recibido no es válido.');
      }

      if (clientes.isEmpty) {
        throw Exception(
          'No se encontró un perfil de cliente asociado a tu cuenta.',
        );
      }

      return Map<String, dynamic>.from(clientes.first as Map);
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('No tienes autorización para consultar tu perfil.');
    }

    throw Exception(
      'No se pudo consultar tu perfil (HTTP ${response.statusCode}).',
    );
  }

  Future<Map<String, dynamic>> actualizarMiPerfil({
    required int id,
    required String nombre,
    required String apellido,
    required String telefono,
    String? fechaNacimiento,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Tu sesión ha expirado. Inicia sesión nuevamente.');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/v1/clientes/$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode({
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'telefono': telefono.trim(),
        'fecha_nacimiento': fechaNacimiento,
      }),
    ).timeout(const Duration(seconds: 20));

    dynamic data;

    try {
      data = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta inesperada '
        '(HTTP ${response.statusCode}).',
      );
    }

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data as Map);
    }

    if (response.statusCode == 400) {
      throw Exception('No se pudieron validar los datos: $data');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('No tienes autorización para actualizar este perfil.');
    }

    if (response.statusCode == 404) {
      throw Exception('No se encontró el perfil solicitado.');
    }

    throw Exception(
      'Error al actualizar el perfil (HTTP ${response.statusCode}): $data',
    );
  }

}
