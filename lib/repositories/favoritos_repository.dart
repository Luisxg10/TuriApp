import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritosRepository {
  static const _claveFavoritos = 'lugares_favoritos';

  final SharedPreferencesAsync? preferencias;
  final FirebaseAuth? autenticacion;
  final FirebaseFirestore? firestore;

  FavoritosRepository({this.preferencias, this.autenticacion, this.firestore});

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

  Future<Set<String>> obtenerIdsFavoritos() async {
    final uid = _uid;
    final baseDeDatos = _baseDeDatos;
    if (uid == null || baseDeDatos == null) return _obtenerLocales();

    final coleccion = baseDeDatos
        .collection('users')
        .doc(uid)
        .collection('favoritos');
    final documentos = await coleccion.get();
    final idsLocales = await _obtenerLocales();
    final idsRemotos = documentos.docs.map((documento) => documento.id).toSet();
    final pendientes = idsLocales.difference(idsRemotos);

    if (pendientes.isNotEmpty) {
      final lote = baseDeDatos.batch();
      for (final id in pendientes) {
        lote.set(coleccion.doc(id), {
          'lugarId': id,
          'creadoEn': FieldValue.serverTimestamp(),
        });
      }
      await lote.commit();
    }
    if (idsLocales.isNotEmpty) await _almacenamiento.remove(_claveFavoritos);

    return {...idsRemotos, ...idsLocales};
  }

  Future<void> guardarIdsFavoritos(Set<String> ids) async {
    final uid = _uid;
    final baseDeDatos = _baseDeDatos;
    if (uid == null || baseDeDatos == null) {
      await _almacenamiento.setStringList(_claveFavoritos, ids.toList());
      return;
    }

    final coleccion = baseDeDatos
        .collection('users')
        .doc(uid)
        .collection('favoritos');
    final actuales = await coleccion.get();
    final idsActuales = actuales.docs.map((documento) => documento.id).toSet();
    final lote = baseDeDatos.batch();

    for (final id in idsActuales.difference(ids)) {
      lote.delete(coleccion.doc(id));
    }
    for (final id in ids.difference(idsActuales)) {
      lote.set(coleccion.doc(id), {
        'lugarId': id,
        'creadoEn': FieldValue.serverTimestamp(),
      });
    }

    if (idsActuales.difference(ids).isNotEmpty ||
        ids.difference(idsActuales).isNotEmpty) {
      await lote.commit();
    }
  }

  Future<Set<String>> _obtenerLocales() async {
    final ids = await _almacenamiento.getStringList(_claveFavoritos);
    return (ids ?? <String>[]).toSet();
  }
}
