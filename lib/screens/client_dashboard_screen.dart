import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import 'citas_screen.dart';

class ClientDashboardScreen extends ConsumerStatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  ConsumerState<ClientDashboardScreen> createState() =>
      _ClientDashboardScreenState();
}

class _ClientDashboardScreenState
    extends ConsumerState<ClientDashboardScreen> {
  int _currentIndex = 0;
  late Future<List<dynamic>> _serviciosFuture;

@override
void initState() {
  super.initState();
  _serviciosFuture = ApiService().obtenerServicios();
}

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(authProvider);

    final List<Widget> pages = [
      _buildAgendarTab(),
      _buildCitasTab(),
      _buildResenasTab(),
      _buildPerfilTab(usuario),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Spa Deseo',
          style: TextStyle(
            color: Color(0xFFD92F70),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD92F70)),
            onPressed: () {
              ref.read(authProvider.notifier).cerrarSesion();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFE91E63),
        unselectedItemColor: const Color(0xFFB99AA9),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Mis Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Reseñas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  
Widget _buildAgendarTab() {
  return const CitasScreen();
}

Widget _buildServiceCard(Map<String, dynamic> servicio) {
  final nombre = servicio['nombre']?.toString() ?? 'Servicio';
  final descripcion =
      servicio['descripcion']?.toString() ?? '';

  final precio = servicio['precio'];
  final duracion = servicio['duracion'];

  final precioNumero = precio is num
      ? precio
      : num.tryParse(precio?.toString() ?? '') ?? 0;

  final precioTexto = precioNumero
      .toInt()
      .toString()
      .replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );

  return Card(
    margin: const EdgeInsets.only(bottom: 14),
    elevation: 2,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.spa,
                  color: Color(0xFFE91E63),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D2344),
                      ),
                    ),
                    if (descripcion.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        descripcion,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '\$$precioTexto COP',
                      style: const TextStyle(
                        color: Color(0xFFD92F70),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (duracion != null)
                      Text(
                        'Duración: $duracion minutos',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Servicio seleccionado: $nombre',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Reservar servicio'),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildCitasTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próximas Citas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB82D63),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              leading:
                  Icon(Icons.access_time_filled, color: Color(0xFFE91E63)),
              title: Text('Manicure Semi'),
              subtitle: Text('Fecha: 25 Sep, 2026 - 4:00 PM\nEstado: Confirmada'),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResenasTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tus Valoraciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB82D63),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              leading: Icon(Icons.star, color: Colors.amber),
              title: Text('Excelente servicio'),
              subtitle:
                  Text('El masaje facial estuvo increíble. Muy recomendado.'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfilTab(Usuario? usuario) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFFFDCE9),
            child: Icon(Icons.person, size: 50, color: Color(0xFFD92F70)),
          ),
          const SizedBox(height: 15),
          Text(
            '${usuario?.nombre ?? "Cliente"} ${usuario?.apellido ?? ""}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6D4657),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.email, color: Color(0xFFD92F70)),
            title: const Text('Correo'),
            subtitle: Text(usuario?.email ?? 'No registrado'),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Color(0xFFD92F70)),
            title: const Text('Teléfono'),
            subtitle: Text(usuario?.telefono ?? 'No registrado'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              minimumSize: const Size(double.infinity, 42),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil actualizado')),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              'Editar Datos',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}