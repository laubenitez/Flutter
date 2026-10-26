import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'client_dashboard_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _tieneLongitud = false;
  bool _tieneMayuscula = false;
  bool _tieneMinuscula = false;
  bool _tieneNumero = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validarPassword(String value) {
    setState(() {
      _tieneLongitud = value.length >= 8;
      _tieneMayuscula = value.contains(RegExp(r'[A-Z]'));
      _tieneMinuscula = value.contains(RegExp(r'[a-z]'));
      _tieneNumero = value.contains(RegExp(r'\d'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Center(
            child: Opacity(
              opacity: 0.10,
              child: Image.asset(
                'assets/img/logo-spa-deseo-fucsia.png',
                width: 550,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.spa,
                  size: 250,
                  color: Color(0xFFD92F70),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 420,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8FB).withOpacity(0.82),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(210, 40, 105, 0.18),
                          blurRadius: 35,
                          offset: Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/img/logo-spa-deseo-fucsia.png',
                          width: 95,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.spa,
                            size: 40,
                            color: Color(0xFFD92F70),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            color: Color(0xFFD92F70),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Regístrate para disfrutar de Spa Deseo',
                          style: TextStyle(
                            color: Color(0xFF8D6879),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // NOMBRE Y APELLIDO EN FILA
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Nombre',
                                controller: _nombreController,
                                hintText: 'Tu nombre',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInputField(
                                label: 'Apellido',
                                controller: _apellidoController,
                                hintText: 'Tu apellido',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        _buildInputField(
                          label: 'Teléfono',
                          controller: _telefonoController,
                          hintText: '3001234567',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 10),

                        _buildInputField(
                          label: 'Correo electrónico',
                          controller: _emailController,
                          hintText: 'ejemplo@correo.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),

                        _buildInputField(
                          label: 'Contraseña',
                          controller: _passwordController,
                          hintText: 'Crea tu contraseña',
                          isPassword: true,
                          onChanged: _validarPassword,
                        ),
                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildValidationBadge('8+ Caracteres', _tieneLongitud),
                            _buildValidationBadge('Mayúscula', _tieneMayuscula),
                            _buildValidationBadge('Minúscula', _tieneMinuscula),
                            _buildValidationBadge('Número', _tieneNumero),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF4F91),
                                Color(0xFFE91E63),
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(233, 30, 99, 0.25),
                                blurRadius: 14,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              if (_nombreController.text.isNotEmpty &&
                                  _emailController.text.isNotEmpty) {
                                ref
                                    .read(authProvider.notifier)
                                    .registrarOLoguear(
                                      nombre: _nombreController.text,
                                      apellido: _apellidoController.text,
                                      telefono: _telefonoController.text,
                                      email: _emailController.text,
                                    );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ClientDashboardScreen(),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Registrarse',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '¿Ya tienes cuenta? ',
                              style: TextStyle(
                                color: Color(0xFF795866),
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Inicia sesión',
                                style: TextStyle(
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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

  Widget _buildValidationBadge(String text, bool isMet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMet ? const Color(0xFFE91E63) : const Color(0xFFF3E5ED),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check : Icons.close,
            size: 11,
            color: isMet ? Colors.white : const Color(0xFFB99AA9),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
              color: isMet ? Colors.white : const Color(0xFF8D6879),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB82D63),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(color: Color(0xFF6D4657), fontSize: 12.5),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle:
                  const TextStyle(color: Color(0xFFB99AA9), fontSize: 11.5),
              filled: true,
              fillColor: Colors.white.withOpacity(0.85),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFF2B3CA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFF2B3CA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
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