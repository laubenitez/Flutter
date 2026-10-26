
class Cita {
  final int? id;
  final int clienteId;
  final int manicuristaId;
  final int servicioId;
  final DateTime fecha;
  final String hora;
  final int total;
  final String estado;

  const Cita({
    this.id,
    required this.clienteId,
    required this.manicuristaId,
    required this.servicioId,
    required this.fecha,
    required this.hora,
    required this.total,
    this.estado = 'programada',
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'] as int?,
      clienteId: _idDesdeRelacion(json['cliente']),
      manicuristaId: _idDesdeRelacion(json['manicurista']),
      servicioId: _idDesdeRelacion(json['servicios']),
      fecha: DateTime.parse(json['fecha'].toString()),
      hora: json['hora'].toString(),
      total: int.tryParse(json['total'].toString()) ?? 0,
      estado: json['estado']?.toString() ?? 'programada',
    );
  }

  static int _idDesdeRelacion(dynamic valor) {
    if (valor is int) return valor;
    if (valor is Map && valor['id'] is int) {
      return valor['id'] as int;
    }
    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente': clienteId,
      'manicurista': manicuristaId,
      'servicios': servicioId,
      'fecha':
          '${fecha.year.toString().padLeft(4, '0')}-'
          '${fecha.month.toString().padLeft(2, '0')}-'
          '${fecha.day.toString().padLeft(2, '0')}',
      'hora': hora,
      'total': total,
      'estado': estado,
    };
  }
}
