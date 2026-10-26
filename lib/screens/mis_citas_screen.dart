
import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color rosaCitas = Color(0xFFE91E63);
const Color rosaOscuroCitas = Color(0xFFB82D63);
const Color fondoCitas = Color(0xFFFFF5F8);

class MisCitasScreen extends StatefulWidget {
  const MisCitasScreen({super.key});

  @override
  State<MisCitasScreen> createState() => _MisCitasScreenState();
}

class _MisCitasScreenState extends State<MisCitasScreen> {
  final ApiService _api = ApiService();

  late Future<List<Map<String, dynamic>>> _futureCitas;

  @override
  void initState() {
    super.initState();
    _futureCitas = _cargarCitas();
  }

  Future<List<Map<String, dynamic>>> _cargarCitas() async {
    final resultados = await Future.wait([
      _api.obtenerCitas(),
      _api.obtenerServicios(),
      _api.obtenerManicuristas(),
    ]);

    final citas = resultados[0];
    final servicios = resultados[1];
    final manicuristas = resultados[2];

    final serviciosPorId = <int, Map<String, dynamic>>{};
    for (final item in servicios) {
      if (item is Map) {
        final mapa = Map<String, dynamic>.from(item);
        final id = _id(mapa['id']);
        if (id != null) serviciosPorId[id] = mapa;
      }
    }

    final manicuristasPorId = <int, Map<String, dynamic>>{};
    for (final item in manicuristas) {
      if (item is Map) {
        final mapa = Map<String, dynamic>.from(item);
        final id = _id(mapa['id']);
        if (id != null) manicuristasPorId[id] = mapa;
      }
    }

    final lista = <Map<String, dynamic>>[];

    for (final item in citas) {
      if (item is! Map) continue;

      final cita = Map<String, dynamic>.from(item);
      final servicioId = _id(cita['servicios']);
      final manicuristaId = _id(cita['manicurista']);

      cita['_nombreServicio'] =
          serviciosPorId[servicioId]?['nombre'] ??
          'Servicio #${servicioId ?? '-'}';

      final manicurista = manicuristasPorId[manicuristaId];
      cita['_nombreManicurista'] = manicurista == null
          ? 'Manicurista #${manicuristaId ?? '-'}'
          : '${manicurista['nombre'] ?? ''} '
              '${manicurista['apellido'] ?? ''}'.trim();

      lista.add(cita);
    }

    // Próximas citas primero.
    lista.sort((a, b) {
      final fechaA = DateTime.tryParse(
        '${a['fecha']} ${a['hora']}',
      );
      final fechaB = DateTime.tryParse(
        '${b['fecha']} ${b['hora']}',
      );

      if (fechaA == null || fechaB == null) return 0;
      return fechaA.compareTo(fechaB);
    });

    return lista;
  }

  int? _id(dynamic valor) {
    if (valor is int) return valor;
    if (valor is Map) return _id(valor['id']);
    return int.tryParse(valor?.toString() ?? '');
  }

  Future<void> _actualizar() async {
    setState(() {
      _futureCitas = _cargarCitas();
    });
    await _futureCitas;
  }

  String _fechaTexto(dynamic valor) {
    final fecha = DateTime.tryParse(valor?.toString() ?? '');
    if (fecha == null) return valor?.toString() ?? 'Sin fecha';

    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  String _horaTexto(dynamic valor) {
    if (valor == null) return 'Sin hora';
    final partes = valor.toString().split(':');
    if (partes.length < 2) return valor.toString();
    return '${partes[0].padLeft(2, '0')}:'
        '${partes[1].padLeft(2, '0')}';
  }

  String _dinero(dynamic valor) {
    final numero = valor is num
        ? valor.toInt()
        : int.tryParse(valor?.toString() ?? '') ?? 0;

    return numero.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'programada':
        return Colors.blue;
      case 'en_proceso':
        return Colors.orange.shade800;
      case 'completada':
        return Colors.green.shade700;
      case 'cancelada':
        return Colors.red.shade700;
      default:
        return rosaOscuroCitas;
    }
  }

  String _textoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'en_proceso':
        return 'En proceso';
      case 'programada':
        return 'Programada';
      case 'completada':
        return 'Completada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado.isEmpty ? 'Sin estado' : estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fondoCitas,
      child: RefreshIndicator(
        color: rosaCitas,
        onRefresh: _actualizar,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureCitas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                children: [
                  SizedBox(height: 220),
                  Center(
                    child: CircularProgressIndicator(color: rosaCitas),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),
                  const Icon(
                    Icons.cloud_off,
                    size: 54,
                    color: rosaCitas,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No pudimos cargar tus citas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: rosaOscuroCitas,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _actualizar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Intentar nuevamente'),
                    ),
                  ),
                ],
              );
            }

            final citas = snapshot.data ?? [];

            if (citas.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),
                  const Icon(
                    Icons.calendar_month,
                    size: 68,
                    color: rosaCitas,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Todavía no tienes citas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: rosaOscuroCitas,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cuando reserves un servicio, aparecerá aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Desliza hacia abajo para actualizar.',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'Mis citas',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: rosaOscuroCitas,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tienes ${citas.length} '
                  '${citas.length == 1 ? 'cita registrada' : 'citas registradas'}.',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),
                ...citas.map(_tarjetaCita),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Desliza hacia abajo para actualizar tus citas.',
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tarjetaCita(Map<String, dynamic> cita) {
    final estado = cita['estado']?.toString() ?? 'programada';
    final colorEstado = _colorEstado(estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4C8D8)),
        boxShadow: [
          BoxShadow(
            color: rosaCitas.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: fondoCitas,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.spa,
                  color: rosaCitas,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cita['_nombreServicio']?.toString() ?? 'Servicio',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: rosaOscuroCitas,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manicurista: ${cita['_nombreManicurista']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26),
          _dato(
            Icons.calendar_month,
            'Fecha',
            _fechaTexto(cita['fecha']),
          ),
          const SizedBox(height: 10),
          _dato(
            Icons.access_time,
            'Hora',
            _horaTexto(cita['hora']),
          ),
          const SizedBox(height: 10),
          _dato(
            Icons.payments_outlined,
            'Total',
            '\$${_dinero(cita['total'])}',
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: colorEstado.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _textoEstado(estado),
                style: TextStyle(
                  color: colorEstado,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dato(IconData icono, String titulo, String valor) {
    return Row(
      children: [
        Icon(icono, size: 19, color: rosaCitas),
        const SizedBox(width: 10),
        Text(
          '$titulo: ',
          style: const TextStyle(color: Colors.black54),
        ),
        Expanded(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF44323A),
            ),
          ),
        ),
      ],
    );
  }
}
