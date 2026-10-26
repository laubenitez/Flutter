
import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color rosa = Color(0xFFE91E63);
const Color rosaOscuro = Color(0xFFB82D63);
const Color fondo = Color(0xFFFFF5F8);

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final ApiService _api = ApiService();

  late Future<List<dynamic>> _serviciosFuture;
  late Future<List<dynamic>> _manicuristasFuture;

  int? _servicioId;
  int? _manicuristaId;
  DateTime? _fecha;
  TimeOfDay? _hora;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    _serviciosFuture = _api.obtenerServicios();
    _manicuristasFuture = _api.obtenerManicuristas();
  }

  Future<void> _recargar() async {
    setState(() {
      _cargarDatos();
    });
  }

  String _dinero(dynamic valor) {
    final numero = valor is num
        ? valor.toInt()
        : int.tryParse(valor.toString()) ?? 0;

    return numero.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
  }

  String _fechaTexto(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  String _horaTexto(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateUtils.dateOnly(DateTime.now());

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha ?? hoy,
      firstDate: hoy,
      lastDate: DateTime.now().add(const Duration(days: 180)),
      helpText: 'Selecciona la fecha de tu cita',
      cancelText: 'Cancelar',
      confirmText: 'Continuar',
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

    if (fecha != null && mounted) {
      setState(() => _fecha = fecha);
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _hora ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Selecciona la hora de tu cita',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: rosa),
          ),
          child: child!,
        );
      },
    );

    if (hora != null && mounted) {
      setState(() => _hora = hora);
    }
  }

  Future<void> _reservar(
    List<dynamic> servicios,
    List<dynamic> manicuristas,
  ) async {
    if (_servicioId == null ||
        _manicuristaId == null ||
        _fecha == null ||
        _hora == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona el servicio, la manicurista, la fecha y la hora.'),
        ),
      );
      return;
    }

    final ahora = DateTime.now();
    final fechaHora = DateTime(
      _fecha!.year,
      _fecha!.month,
      _fecha!.day,
      _hora!.hour,
      _hora!.minute,
    );

    if (!fechaHora.isAfter(ahora)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una fecha y hora futuras.'),
        ),
      );
      return;
    }

    final servicio = servicios.cast<Map>().firstWhere(
      (s) => s['id'] == _servicioId,
    );

    final precio = servicio['precio'] is num
        ? (servicio['precio'] as num).toInt()
        : int.tryParse(servicio['precio'].toString()) ?? 0;

    setState(() => _guardando = true);

    try {
      await _api.crearCita(
        manicuristaId: _manicuristaId!,
        servicioId: _servicioId!,
        fecha: _fecha!,
        hora: _horaTexto(_hora!),
        total: precio,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Tu cita fue registrada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _servicioId = null;
        _manicuristaId = null;
        _fecha = null;
        _hora = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo reservar: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fondo,
      child: FutureBuilder<List<dynamic>>(
        future: _serviciosFuture,
        builder: (context, serviciosSnapshot) {
          if (serviciosSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: rosa),
            );
          }

          if (serviciosSnapshot.hasError) {
            return _error(
              'No se pudieron cargar los servicios.',
              serviciosSnapshot.error,
            );
          }

          final servicios = (serviciosSnapshot.data ?? [])
              .where((item) =>
                  item is Map &&
                  item['estado']?.toString().toLowerCase() == 'activo')
              .toList();

          return FutureBuilder<List<dynamic>>(
            future: _manicuristasFuture,
            builder: (context, manicuristasSnapshot) {
              if (manicuristasSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: rosa),
                );
              }

              if (manicuristasSnapshot.hasError) {
                return _error(
                  'No se pudieron cargar las manicuristas.',
                  manicuristasSnapshot.error,
                );
              }

              final manicuristas = manicuristasSnapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Text(
                    'Agenda tu cita',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: rosaOscuro,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Elige tu servicio favorito y encuentra el momento ideal para consentirte.',
                    style: TextStyle(color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 22),
                  _seccion('1. Selecciona un servicio'),
                  DropdownButtonFormField<int>(
                    value: _servicioId,
                    isExpanded: true,
                    decoration: _decoracion('Servicio', Icons.spa),
                    items: servicios.map((item) {
                      final s = Map<String, dynamic>.from(item as Map);
                      return DropdownMenuItem<int>(
                        value: s['id'] as int,
                        child: Text(
                          '${s['nombre']} · \$${_dinero(s['precio'])}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _servicioId = value);
                    },
                  ),
                  if (_servicioId == null && servicios.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('No hay servicios activos disponibles.'),
                    ),
                  const SizedBox(height: 20),
                  _seccion('2. Elige tu manicurista'),
                  DropdownButtonFormField<int>(
                    value: _manicuristaId,
                    isExpanded: true,
                    decoration: _decoracion(
                      'Manicurista',
                      Icons.person_outline,
                    ),
                    items: manicuristas.map((item) {
                      final m = Map<String, dynamic>.from(item as Map);
                      return DropdownMenuItem<int>(
                        value: m['id'] as int,
                        child: Text(
                          '${m['nombre']} ${m['apellido']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _manicuristaId = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  _seccion('3. Fecha y hora'),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _seleccionarFecha,
                          icon: const Icon(Icons.calendar_month),
                          label: Text(
                            _fecha == null
                                ? 'Elegir fecha'
                                : _fechaTexto(_fecha!),
                          ),
                          style: _botonSecundario(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _seleccionarHora,
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            _hora == null
                                ? 'Elegir hora'
                                : _hora!.format(context),
                          ),
                          style: _botonSecundario(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (_servicioId != null)
                    _resumen(servicios),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _guardando ||
                              servicios.isEmpty ||
                              manicuristas.isEmpty
                          ? null
                          : () => _reservar(servicios, manicuristas),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rosa,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.pink.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _guardando ? 'Registrando...' : 'Confirmar reserva',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _guardando ? null : _recargar,
                    icon: const Icon(Icons.refresh, color: rosa),
                    label: const Text(
                      'Actualizar disponibilidad',
                      style: TextStyle(color: rosaOscuro),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6D2344),
        ),
      ),
    );
  }

  InputDecoration _decoracion(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: rosa),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF4C8D8)),
      ),
    );
  }

  ButtonStyle _botonSecundario() {
    return OutlinedButton.styleFrom(
      foregroundColor: rosaOscuro,
      side: const BorderSide(color: Color(0xFFF0B7CB)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _resumen(List<dynamic> servicios) {
    final servicio = servicios.cast<Map>().firstWhere(
      (s) => s['id'] == _servicioId,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF4C8D8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: rosa, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de tu servicio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: rosaOscuro,
                  ),
                ),
                const SizedBox(height: 4),
                Text(servicio['nombre'].toString()),
              ],
            ),
          ),
          Text(
            '\$${_dinero(servicio['precio'])}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: rosaOscuro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _error(String mensaje, Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 45, color: rosa),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _recargar,
              child: const Text('Intentar nuevamente'),
            ),
          ],
        ),
      ),
    );
  }
}
