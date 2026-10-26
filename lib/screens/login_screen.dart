import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'client_dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? mensajeError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // FONDO GRADIENTE
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFDCE9),
                  Color(0xFFFFC6DA),
                  Color(0xFFFF9FBE),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // MARCA DE AGUA
          Center(
            child: Opacity(
              opacity: 0.10,
              child: Image.asset(
                'assets/img/logo-spa-deseo-fucsia.png',
                width: 600,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.spa,
                  size: 300,
                  color: Color(0xFFD92F70),
                ),
              ),
            ),
          ),

          // TARJETA DE LOGIN
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8FB).withOpacity(0.78),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.75),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(210, 40, 105, 0.20),
                          blurRadius: 45,
                          offset: Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/img/logo-spa-deseo-fucsia.png',
                          width: 140,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.spa,
                            size: 60,
                            color: Color(0xFFD92F70),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Color(0xFFD92F70),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Bienvenido a Spa Deseo',
                          style: TextStyle(
                            color: Color(0xFF8D6879),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 25),

                        if (mensajeError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE0E3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              mensajeError!,
                              style: const TextStyle(
                                color: Color(0xFFD92F70),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],

                        _buildInputField(
                          label: 'Correo electrónico',
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          hintText: 'ejemplo@correo.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          label: 'Contraseña',
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          hintText: '••••••••',
                          isPassword: true,
                        ),
                        const SizedBox(height: 24),

                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF4F91),
                                Color(0xFFE91E63),
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(233, 30, 99, 0.25),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            
                            onPressed: () async {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text;

                              if (email.isEmpty || password.isEmpty) {
                                setState(() {
                                  mensajeError = 'Ingresa tu correo y contraseña.';
                                });
                                return;
                              }

                              setState(() {
                                mensajeError = null;
                              });

                              final notifier = ref.read(authProvider.notifier);

                              // Mostrar progreso mientras responde Django.
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFE91E63),
                                  ),
                                ),
                              );

                              bool correcto = false;

                              try {
                                correcto = await notifier.login(
                                  email: email,
                                  password: password,
                                );
                              } finally {
                                if (mounted && Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                              }

                              if (!mounted) return;

                              if (correcto) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ClientDashboardScreen(),
                                  ),
                                );
                              } else {
                                setState(() {
                                  mensajeError =
                                      notifier.errorMessage ?? 'No fue posible iniciar sesión.';
                                });
                              }
                            },

                            child: const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '¿No tienes una cuenta? ',
                              style: TextStyle(
                                color: Color(0xFF795866),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Regístrate',
                                style: TextStyle(
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB82D63),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 45,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: const TextStyle(color: Color(0xFF6D4657), fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFD92F70), size: 20),
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFFB99AA9)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.80),
              contentPadding: const EdgeInsets.symmetric(horizontal: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFF2B3CA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFF2B3CA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFEF3F7C), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}