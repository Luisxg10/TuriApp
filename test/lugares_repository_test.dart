import 'package:flutter_test/flutter_test.dart';
import 'package:turisags/repositories/lugares_repository.dart';

void main() {
  test('El repositorio devuelve tres lugares turísticos', () {
    const repository = LugaresRepository();

    final lugares = repository.obtenerLugares();

    expect(lugares.length, 3);

    expect(lugares[0].nombre, 'Plaza de la Patria');

    expect(lugares[1].nombre, 'Jardín de San Marcos');

    expect(lugares[2].nombre, 'Museo Nacional de la Muerte');
  });
}
