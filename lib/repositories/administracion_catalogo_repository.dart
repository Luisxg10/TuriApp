import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/lugar_turistico.dart';

class AdministracionCatalogoRepository {
  AdministracionCatalogoRepository({
    FirebaseAuth? autenticacion,
    FirebaseFirestore? firestore,
  }) : _autenticacion = autenticacion ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _autenticacion;
  final FirebaseFirestore _firestore;

  Future<bool> esAdministrador([String? uid]) async {
    final idUsuario = uid ?? _autenticacion.currentUser?.uid;
    if (idUsuario == null) return false;

    final documento = await _firestore
        .collection('administradores')
        .doc(idUsuario)
        .get();
    return documento.data()?['activo'] == true;
  }

  Future<List<LugarTuristico>> obtenerLugares() async {
    if (!await esAdministrador()) {
      throw StateError('La cuenta no tiene permisos de administrador.');
    }

    final documentos = await _firestore
        .collection('lugares')
        .orderBy('nombre')
        .get();
    return documentos.docs
        .map(
          (documento) =>
              LugarTuristico.fromFirestore(documento.id, documento.data()),
        )
        .toList();
  }

  Future<void> guardarLugar(LugarTuristico lugar) async {
    if (!await esAdministrador()) {
      throw StateError('La cuenta no tiene permisos de administrador.');
    }
    if (lugar.imagenAsset == null || lugar.imagenAsset!.isEmpty) {
      throw StateError('Selecciona una imagen incluida en la aplicación.');
    }

    final coleccion = _firestore.collection('lugares');
    final referencia = lugar.id.isEmpty ? coleccion.doc() : coleccion.doc(lugar.id);
    await referencia.set(lugar.toFirestore());
  }

  Future<void> eliminarLugar(LugarTuristico lugar) async {
    if (!await esAdministrador()) {
      throw StateError('La cuenta no tiene permisos de administrador.');
    }
    await _firestore.collection('lugares').doc(lugar.id).delete();
  }
}
