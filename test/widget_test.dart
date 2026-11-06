import 'package:flutter_test/flutter_test.dart';
import 'package:turisags/app/turisags_app.dart';

void main() {
  testWidgets('Navegación al catálogo y detalles turísticos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TurisAGSApp());
    await tester.pumpAndSettle();

    expect(find.text('Lugares turísticos'), findsOneWidget);

    await tester.tap(find.text('Jardín de San Marcos'));
    await tester.pumpAndSettle();

    expect(find.text('Detalles del lugar'), findsOneWidget);

    expect(find.text('Jardín de San Marcos'), findsOneWidget);

    expect(find.text('Barrio de San Marcos'), findsOneWidget);
  });
}
