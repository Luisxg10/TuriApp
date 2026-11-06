import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/visita_planeada.dart';

class ItinerarioRepository {
  static const _claveItinerario = 'itinerario_visitas';
  final SharedPreferencesAsync? preferencias;

  ItinerarioRepository({this.preferencias});

  Future<List<VisitaPlaneada>> obtenerVisitas() async {
    final almacenamiento = preferencias ?? SharedPreferencesAsync();
    final contenido = await almacenamiento.getString(_claveItinerario);
    if (contenido == null || contenido.isEmpty) return [];

    final datos = jsonDecode(contenido) as List<dynamic>;
    return datos
        .map(
          (dato) => VisitaPlaneada.fromJson(dato as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> guardarVisitas(List<VisitaPlaneada> visitas) async {
    final almacenamiento = preferencias ?? SharedPreferencesAsync();
    final contenido = jsonEncode(visitas.map((visita) => visita.toJson()).toList());
    await almacenamiento.setString(_claveItinerario, contenido);
  }
}
