import 'package:flutter_test/flutter_test.dart';
import 'package:turisags/repositories/lugares_repository.dart';
import 'package:turisags/viewmodels/lugares_viewmodel.dart';

void main() {
  test('El ViewModel obtiene los lugares del repositorio', () {
    final viewModel = LugaresViewModel(repository: const LugaresRepository());

    final lugares = viewModel.obtenerLugares();

    expect(lugares.length, 3);
    expect(lugares[0].nombre, 'Plaza de la Patria');
    expect(lugares[1].nombre, 'Jardín de San Marcos');
    expect(lugares[2].nombre, 'Museo Nacional de la Muerte');
  });
}
