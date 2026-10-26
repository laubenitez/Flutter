
import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color rosaResenas = Color(0xFFE91E63);
const Color oscuroResenas = Color(0xFFB82D63);
const Color fondoResenas = Color(0xFFFFF5F8);

class ResenasScreen extends StatefulWidget {
  const ResenasScreen({super.key});

  @override
  State<ResenasScreen> createState() => _ResenasScreenState();
}

class _ResenasScreenState extends State<ResenasScreen> {
  final ApiService _api = ApiService();

  late Future<_DatosResenas> _future;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<_DatosResenas> _cargar() async {
    final resultados = await Future.wait([
      _api.obtenerResenas(),
      _api.obtenerCitas(),
    ]);

    return _DatosResenas(
      resenas: resultados[0]
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      citas: resultados[1]
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  Future<void> _actualizar() async {
    final nuevoFuture = _cargar();
    setState(() => _future = nuevoFuture);

    try {
      await nuevoFuture;
    } catch (_) {
      // FutureBuilder mostrará el error.
    }
  }

  int? _id(dynamic value) {
    if (value is int) return value;
    if (value is Map) return _id(value['id']);
    return int.tryParse(value?.toString() ?? '');
  }

  String _fecha(dynamic value) {
    final fecha = DateTime.tryParse(value?.toString() ?? '');
    if (fecha == null) return value?.toString() ?? '';

    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  String _nombreServicio(Map<String, dynamic> cita) {
    final servicio = cita['servicios'];

    if (servicio is Map) {
      return servicio['nombre']?.toString() ?? 'Servicio';
    }

    return 'Servicio #${_id(servicio) ?? '-'}';
  }

  Future<void> _nuevaResena(Map<String, dynamic> cita) async {
    final citaId = _id(cita['id']);

    if (citaId == null) {
      _mensaje('No se pudo identificar la cita.');
      return;
    }

    int calificacion = 5;
    final comentarioController = TextEditingController();

    final datos = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Califica tu experiencia',
                style: TextStyle(color: oscuroResenas),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_nombreServicio(cita)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final numero = index + 1;

                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              calificacion = numero;
                            });
                          },
                          icon: Icon(
                            numero <= calificacion
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber.shade700,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    TextField(
                      controller: comentarioController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Comentario (opcional)',
                        hintText: 'Cuéntanos cómo fue tu experiencia',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rosaResenas,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext, {
                      'calificacion': calificacion,
                      'comentario': comentarioController.text.trim(),
                    });
                  },
                  child: const Text('Enviar reseña'),
                ),
              ],
            );
          },
        );
      },
    );

    comentarioController.dispose();

    if (datos == null || !mounted) return;

    setState(() => _guardando = true);

    try {
      await _api.crearResena(
        citaId: citaId,
        calificacion: datos['calificacion'] as int,
        comentario: datos['comentario'] as String,
      );

      if (!mounted) return;

      _mensaje('¡Gracias por compartir tu experiencia!');
      await _actualizar();
    } catch (e) {
      if (mounted) _mensaje('No se pudo guardar la reseña: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fondoResenas,
      child: FutureBuilder<_DatosResenas>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: rosaResenas),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      color: rosaResenas,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No pudimos cargar tus reseñas.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _actualizar,
                      child: const Text('Intentar nuevamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final datos = snapshot.data!;
          final resenas = datos.resenas;
          final citasCompletadas = datos.citas.where((cita) {
            return cita['estado']?.toString().toLowerCase() ==
                'completada';
          }).toList();

          final citasResenadas = resenas
              .map((r) => _id(r['cita']))
              .whereType<int>()
              .toSet();

          final pendientes = citasCompletadas.where((cita) {
            final id = _id(cita['id']);
            return id != null && !citasResenadas.contains(id);
          }).toList();

          return RefreshIndicator(
            color: rosaResenas,
            onRefresh: _actualizar,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'Mis reseñas',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: oscuroResenas,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tus experiencias y valoraciones en Spa Deseo.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),

                if (resenas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 56,
                          color: rosaResenas,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Todavía no has publicado reseñas.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                ...resenas.map(_tarjetaResena),

                if (pendientes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Servicios por calificar',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: oscuroResenas,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...pendientes.map((cita) {
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(
                          Icons.rate_review_outlined,
                          color: rosaResenas,
                        ),
                        title: Text(_nombreServicio(cita)),
                        subtitle: Text(
                          'Fecha: ${_fecha(cita['fecha'])}',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: rosaResenas,
                        ),
                        onTap: _guardando
                            ? null
                            : () => _nuevaResena(cita),
                      ),
                    );
                  }),
                ],

                if (citasCompletadas.isEmpty && resenas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Cuando completes una cita, podrás dejar tu valoración.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tarjetaResena(Map<String, dynamic> resena) {
    final calificacion =
        int.tryParse(resena['calificacion'].toString()) ?? 0;
    final comentario = resena['comentario']?.toString().trim() ?? '';
    final servicio =
        resena['servicio_nombre']?.toString() ?? 'Servicio';
    final fecha = _fecha(resena['fecha_cita']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFF4C8D8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              servicio,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: oscuroResenas,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < calificacion ? Icons.star : Icons.star_border,
                  color: Colors.amber.shade700,
                  size: 22,
                );
              }),
            ),
            if (comentario.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(comentario),
            ],
            if (fecha.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Fecha de la cita: $fecha',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DatosResenas {
  final List<Map<String, dynamic>> resenas;
  final List<Map<String, dynamic>> citas;

  const _DatosResenas({
    required this.resenas,
    required this.citas,
  });
}
