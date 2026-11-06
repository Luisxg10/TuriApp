import '../models/lugar_turistico.dart';
import '../repositories/lugares_repository.dart';

class LugaresViewModel {
  final LugaresRepository repository;

  LugaresViewModel({required this.repository});

  List<LugarTuristico> obtenerLugares() {
    return repository.obtenerLugares();
  }

  List<String> obtenerCategorias() {
    final categorias = obtenerLugares()
        .map((lugar) => lugar.categoria)
        .toSet()
        .toList()
      ..sort();
    return ['Todos', ...categorias];
  }

  List<LugarTuristico> buscarYFiltrar({
    required String texto,
    required String categoria,
  }) {
    final consulta = texto.trim().toLowerCase();

    return obtenerLugares().where((lugar) {
      final coincideCategoria =
          categoria == 'Todos' || lugar.categoria == categoria;
      final coincideTexto = consulta.isEmpty ||
          lugar.nombre.toLowerCase().contains(consulta) ||
          lugar.descripcion.toLowerCase().contains(consulta) ||
          lugar.ubicacion.toLowerCase().contains(consulta);

      return coincideCategoria && coincideTexto;
    }).toList();
  }
}
