import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class Usuario {
  final String nombre;
  final String apellido;
  final String telefono;
  final String email;

  Usuario({
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.email,
  });
}

class AuthNotifier extends StateNotifier<Usuario?> {
  AuthNotifier() : super(null);

  final ApiService _apiService = ApiService();

  String? errorMessage;
  bool isLoading = false;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;

    try {
      final correcto = await _apiService.login(
        email: email,
        password: password,
      );

      if (!correcto) {
        errorMessage = 'Correo o contraseña incorrectos.';
        return false;
      }

      state = Usuario(
        nombre: '',
        apellido: '',
        telefono: '',
        email: email.trim(),
      );

      return true;
    } catch (e) {
      errorMessage = e.toString().contains('TimeoutException')
          ? 'El servidor tardó demasiado en responder.'
          : 'No fue posible conectar con el servidor.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  void registrarOLoguear({
    required String nombre,
    required String apellido,
    required String telefono,
    required String email,
  }) {
    // Se conserva temporalmente para no romper
    // las pantallas que ya llaman a este método.
    state = Usuario(
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      email: email,
    );
  }

  Future<void> cerrarSesion() async {
    await _apiService.logout();
    state = null;
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, Usuario?>((ref) {
  return AuthNotifier();
});
