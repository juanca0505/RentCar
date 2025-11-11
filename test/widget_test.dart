import 'package:flutter_test/flutter_test.dart';
import 'package:rentacar_flutter/main.dart';

void main() {
  testWidgets('App carga correctamente', (WidgetTester tester) async {
    // Cargar la aplicación principal RentACarApp
    await tester.pumpWidget(const RentACarApp());

    // Verificar que se renderiza correctamente el texto del login
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
