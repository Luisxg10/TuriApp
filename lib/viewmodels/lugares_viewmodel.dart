import 'package:flutter/foundation.dart';

import '../models/lugar_turistico.dart';
import '../repositories/lugares_repository.dart';

class LugaresViewModel extends ChangeNotifier {
  final LugaresRepository repository;

  LugaresViewModel({required this.repository});

  List<LugarTuristico> lugares = [];
  bool cargando = true;
  bool catalogoLocal = false;
  String? mensaje;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> cargarLugares({bool actualizar = false}) async {
    cargando = true;
    _notificarSiDisponible();

    final resultado = await repository.cargarLugares(actualizar: actualizar);
    lugares = resultado.lugares;
    catalogoLocal = resultado.esLocal;
    mensaje = resultado.mensaje;
    cargando = false;
    _notificarSiDisponible();
  }

  void _notificarSiDisponible() {
    if (!_disposed) notifyListeners();
  }

  List<LugarTuristico> obtenerLugares() =>
      lugares.isEmpty ? repository.obtenerLugares() : lugares;

  List<String> obtenerCategorias() {
    final categorias = lugares.map((lugar) => lugar.categoria).toSet().toList()
      ..sort();
    return ['Todos', ...categorias];
  }

  List<LugarTuristico> buscarYFiltrar({
    required String texto,
    required String categoria,
  }) {
    final consulta = texto.trim().toLowerCase();

    return lugares.where((lugar) {
      final coincideCategoria =
          categoria == 'Todos' || lugar.categoria == categoria;
      final coincideTexto =
          consulta.isEmpty ||
          lugar.nombre.toLowerCase().contains(consulta) ||
          lugar.descripcion.toLowerCase().contains(consulta) ||
          lugar.ubicacion.toLowerCase().contains(consulta);

      return coincideCategoria && coincideTexto;
    }).toList();
  }
}
