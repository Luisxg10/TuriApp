import 'package:flutter/foundation.dart';

import '../models/visita_planeada.dart';
import '../repositories/itinerario_repository.dart';

class ItinerarioViewModel extends ChangeNotifier {
  final ItinerarioRepository repository;

  ItinerarioViewModel({required this.repository});

  List<VisitaPlaneada> visitas = [];
  bool cargando = true;

  Future<void> cargarVisitas() async {
    try {
      visitas = await repository.obtenerVisitas();
      _ordenarVisitas();
    } catch (_) {
      visitas = [];
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> programarVisita(String lugarId, DateTime fecha) async {
    final fechaDia = DateTime(fecha.year, fecha.month, fecha.day);
    final nuevasVisitas = visitas
        .where(
          (visita) =>
              visita.lugarId != lugarId || !_mismoDia(visita.fecha, fechaDia),
        )
        .toList()
      ..add(VisitaPlaneada(lugarId: lugarId, fecha: fechaDia));

    return _guardar(nuevasVisitas);
  }

  Future<bool> eliminarVisita(String id) async {
    final nuevasVisitas = visitas.where((visita) => visita.id != id).toList();
    return _guardar(nuevasVisitas);
  }

  Future<bool> _guardar(List<VisitaPlaneada> nuevasVisitas) async {
    _ordenar(nuevasVisitas);
    try {
      await repository.guardarVisitas(nuevasVisitas);
      visitas = nuevasVisitas;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _ordenarVisitas() => _ordenar(visitas);

  void _ordenar(List<VisitaPlaneada> elementos) {
    elementos.sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
