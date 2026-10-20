import 'package:flutter_test/flutter_test.dart';
import 'package:turisags/app/turisags_app.dart';

void main() {
  testWidgets('Navegación al catálogo turístico', (WidgetTester tester) async {
    await tester.pumpWidget(const TurisAGSApp());

    expect(find.text('Bienvenido a TurisAGS'), findsOneWidget);

    await tester.tap(find.text('Explorar lugares'));

    await tester.pumpAndSettle();

    expect(find.text('Lugares turísticos'), findsOneWidget);

    expect(find.text('Plaza de la Patria'), findsOneWidget);

    expect(find.text('Jardín de San Marcos'), findsOneWidget);
  });
}
