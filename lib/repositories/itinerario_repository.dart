import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/visita_planeada.dart';

class ItinerarioRepository {
  static const _claveItinerario = 'itinerario_visitas';

  final SharedPreferencesAsync? preferencias;
  final FirebaseAuth? autenticacion;
  final FirebaseFirestore? firestore;

  ItinerarioRepository({this.preferencias, this.autenticacion, this.firestore});

  SharedPreferencesAsync get _almacenamiento =>
      preferencias ?? SharedPreferencesAsync();

  String? get _uid {
    if (autenticacion == null && Firebase.apps.isEmpty) return null;
    return (autenticacion ?? FirebaseAuth.instance).currentUser?.uid;
  }

  FirebaseFirestore? get _baseDeDatos {
    if (firestore == null && Firebase.apps.isEmpty) return null;
    return firestore ?? FirebaseFirestore.instance;
  }

  Future<List<VisitaPlaneada>> obtenerVisitas() async {
    final uid = _uid;
    final baseDeDatos = _baseDeDatos;
    if (uid == null || baseDeDatos == null) return _obtenerLocales();

    final coleccion = baseDeDatos
        .collection('users')
        .doc(uid)
        .collection('itinerario');
    final documentos = await coleccion.get();
    final visitasRemotas = documentos.docs
        .map((documento) => VisitaPlaneada.fromJson(documento.data()))
        .toList();
    final visitasLocales = await _obtenerLocales();
    final idsRemotos = visitasRemotas.map((visita) => visita.id).toSet();
    final pendientes = visitasLocales
        .where((visita) => !idsRemotos.contains(visita.id))
        .toList();

    if (pendientes.isNotEmpty) {
      final lote = baseDeDatos.batch();
      for (final visita in pendientes) {
        lote.set(coleccion.doc(visita.id), visita.toJson());
      }
      await lote.commit();
    }
    if (visitasLocales.isNotEmpty) {
      await _almacenamiento.remove(_claveItinerario);
    }

    return [...visitasRemotas, ...pendientes];
  }

  Future<void> guardarVisitas(List<VisitaPlaneada> visitas) async {
    final uid = _uid;
    final baseDeDatos = _baseDeDatos;
    if (uid == null || baseDeDatos == null) {
      final contenido = jsonEncode(
        visitas.map((visita) => visita.toJson()).toList(),
      );
      await _almacenamiento.setString(_claveItinerario, contenido);
      return;
    }

    final coleccion = baseDeDatos
        .collection('users')
        .doc(uid)
        .collection('itinerario');
    final actuales = await coleccion.get();
    final idsNuevos = visitas.map((visita) => visita.id).toSet();
    final idsActuales = actuales.docs.map((documento) => documento.id).toSet();
    final lote = baseDeDatos.batch();

    for (final id in idsActuales.difference(idsNuevos)) {
      lote.delete(coleccion.doc(id));
    }
    for (final visita in visitas) {
      lote.set(coleccion.doc(visita.id), visita.toJson());
    }

    if (idsActuales.difference(idsNuevos).isNotEmpty || visitas.isNotEmpty) {
      await lote.commit();
    }
  }

  Future<List<VisitaPlaneada>> _obtenerLocales() async {
    final contenido = await _almacenamiento.getString(_claveItinerario);
    if (contenido == null || contenido.isEmpty) return [];

    final datos = jsonDecode(contenido) as List<dynamic>;
    return datos
        .map((dato) => VisitaPlaneada.fromJson(dato as Map<String, dynamic>))
        .toList();
  }
}
