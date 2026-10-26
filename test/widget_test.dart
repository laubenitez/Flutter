// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spadeseo/main.dart';

void main() {
  testWidgets('Navega de Bienvenida a Login al presionar Comenzar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Presiona el botón Comenzar
    await tester.tap(find.widgetWithText(ElevatedButton, 'Comenzar'));
    await tester.pumpAndSettle(); // Espera a que termine la animación de navegación

    // Verifica que estamos en la pantalla de Iniciar Sesión
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}