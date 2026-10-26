
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final ApiService _apiService = ApiService();

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();

  Map<String, dynamic>? _perfil;
  DateTime? _fechaNacimiento;
  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  static const Color rosa = Color(0xFFD92F70);
  static const Color fondo = Color(0xFFFFF5F8);

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final perfil = await _apiService.obtenerMiPerfil();

      if (!mounted) return;

      _nombreController.text = perfil['nombre']?.toString() ?? '';
      _apellidoController.text = perfil['apellido']?.toString() ?? '';
      _telefonoController.text = perfil['telefono']?.toString() ?? '';

      final fecha = perfil['fecha_nacimiento']?.toString();

      if (fecha != null && fecha.isNotEmpty) {
        _fechaNacimiento = DateTime.tryParse(fecha);
      }

      setState(() {
        _perfil = perfil;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(hoy.year - 18, hoy.month, hoy.day),
      firstDate: DateTime(1900),
      lastDate: hoy,
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: rosa,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF6D2344),
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() => _fechaNacimiento = fecha);
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    if (_perfil == null) return;

    setState(() => _guardando = true);

    try {
      final fecha = _fechaNacimiento == null
          ? null
          : '${_fechaNacimiento!.year.toString().padLeft(4, '0')}-'
            '${_fechaNacimiento!.month.toString().padLeft(2, '0')}-'
            '${_fechaNacimiento!.day.toString().padLeft(2, '0')}';

      final actualizado = await _apiService.actualizarMiPerfil(
        id: int.parse(_perfil!['id'].toString()),
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        telefono: _telefonoController.text,
        fechaNacimiento: fecha,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Perfil actualizado correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, actualizado);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: fondo,
        body: Center(
          child: CircularProgressIndicator(color: rosa),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: fondo,
        appBar: AppBar(
          title: const Text('Editar perfil'),
          foregroundColor: rosa,
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: rosa, size: 48),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _cargando = true;
                      _error = null;
                    });
                    _cargarPerfil();
                  },
                  child: const Text('Intentar nuevamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text(
          'Editar perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: rosa,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Color(0xFFFFDCE9),
                    child: Icon(Icons.person, size: 52, color: rosa),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Actualiza tus datos personales',
                    style: TextStyle(
                      color: Color(0xFF6D2344),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _campo(
                  etiqueta: 'Nombre',
                  controller: _nombreController,
                  icono: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _campo(
                  etiqueta: 'Apellido',
                  controller: _apellidoController,
                  icono: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _campo(
                  etiqueta: 'Teléfono',
                  controller: _telefonoController,
                  icono: Icons.phone_outlined,
                  tipo: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Correo electrónico',
                  style: TextStyle(
                    color: Color(0xFF6D2344),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _perfil?['email']?.toString() ?? '',
                  readOnly: true,
                  decoration: _decoracion(
                    'Correo electrónico',
                    Icons.email_outlined,
                  ).copyWith(
                    filled: true,
                    fillColor: const Color(0xFFFFE9F0),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fecha de nacimiento',
                  style: TextStyle(
                    color: Color(0xFF6D2344),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _seleccionarFecha,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _decoracion(
                      'Selecciona tu fecha de nacimiento',
                      Icons.calendar_month_outlined,
                    ),
                    child: Text(
                      _fechaNacimiento == null
                          ? 'No seleccionada'
                          : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/'
                            '${_fechaNacimiento!.month.toString().padLeft(2, '0')}/'
                            '${_fechaNacimiento!.year}',
                      style: TextStyle(
                        color: _fechaNacimiento == null
                            ? Colors.black54
                            : const Color(0xFF6D2344),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _guardando ? null : _guardarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rosa,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _guardando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _guardando ? 'Guardando...' : 'Guardar cambios',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required String etiqueta,
    required TextEditingController controller,
    required IconData icono,
    TextInputType tipo = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            color: Color(0xFF6D2344),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: tipo,
          textCapitalization: tipo == TextInputType.text
              ? TextCapitalization.words
              : TextCapitalization.none,
          decoration: _decoracion(etiqueta, icono),
          validator: (valor) {
            if (valor == null || valor.trim().isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _decoracion(String texto, IconData icono) {
    return InputDecoration(
      hintText: texto,
      prefixIcon: Icon(icono, color: rosa),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF3C4D5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF3C4D5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: rosa, width: 1.5),
      ),
    );
  }
}
