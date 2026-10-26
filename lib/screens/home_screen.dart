import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Mi Proyecto Spadeseo',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¡Bienvenido a la aplicación!'),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Guardar',
              color: Colors.green,
              onPressed: () {
                print('Guardado correctamente');
              },
            ),
          ],
        ),
      ),
    );
  }
}