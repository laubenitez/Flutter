import 'package:flutter_riverpod/flutter_riverpod.dart';

// Estado que guardará nuestro login (si está cargando, si hay error o éxito)
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isLoggedIn;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isLoggedIn,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

// Controlador Reactivo del Login
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<bool> login(String email, String password) async {
    // 1. Activamos el estado de carga (Reactividad pura)
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Simulamos una petición a un servidor (red) de 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    // Validación simple de ejemplo
    if (email == "admin@app.com" && password == "123456") {
      state = state.copyWith(isLoading: false, isLoggedIn: true);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: 'Correo o contraseña incorrectos',
      );
      return false;
    }
  }
}

// Proveedor global para consumir este controlador en la UI
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});