import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/lugar_turistico.dart';

class AdministracionCatalogoRepository {
  AdministracionCatalogoRepository({
    FirebaseAuth? autenticacion,
    FirebaseFirestore? firestore,
    FirebaseStorage? almacenamiento,
  }) : _autenticacion = autenticacion ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _almacenamientoInyectado = almacenamiento;

  final FirebaseAuth _autenticacion;
  final FirebaseFirestore _firestore;
  final FirebaseStorage? _almacenamientoInyectado;

  FirebaseStorage get _almacenamiento =>
      _almacenamientoInyectado ?? FirebaseStorage.instance;

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

  Future<void> guardarLugar({
    required LugarTuristico lugar,
    XFile? imagenNueva,
    ValueChanged<double>? alCambiarProgreso,
  }) async {
    if (!await esAdministrador()) {
      throw StateError('La cuenta no tiene permisos de administrador.');
    }

    final coleccion = _firestore.collection('lugares');
    final referenciaDocumento = lugar.id.isEmpty
        ? coleccion.doc()
        : coleccion.doc(lugar.id);
    final existente = await referenciaDocumento.get();
    var imagenUrl = lugar.imagenUrl;
    var rutaImagen = lugar.imagenStoragePath;
    String? nuevaRutaSubida;

    if (imagenNueva != null) {
      final tipo = _tipoImagen(imagenNueva.name);
      final bytes = await imagenNueva.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        throw StateError('La imagen debe pesar menos de 5 MB.');
      }

      final nombreArchivo =
          'portada_${DateTime.now().microsecondsSinceEpoch}.$tipo';
      final referenciaImagen = _almacenamiento.ref().child(
        'lugares/${referenciaDocumento.id}/$nombreArchivo',
      );
      final tarea = referenciaImagen.putData(
        bytes,
        SettableMetadata(contentType: _mimeType(tipo)),
      );
      final suscripcion = tarea.snapshotEvents.listen((evento) {
        if (evento.totalBytes > 0) {
          alCambiarProgreso?.call(evento.bytesTransferred / evento.totalBytes);
        }
      });

      try {
        await tarea;
        imagenUrl = await referenciaImagen.getDownloadURL();
        rutaImagen = referenciaImagen.fullPath;
        nuevaRutaSubida = rutaImagen;
      } finally {
        await suscripcion.cancel();
      }
    } else if (!existente.exists && (imagenUrl == null || imagenUrl.isEmpty)) {
      throw StateError('Selecciona una imagen para el nuevo lugar.');
    }

    final datos = lugar.toFirestore();
    if (imagenNueva != null) datos.remove('imagenAsset');
    if (imagenUrl != null) datos['imagenUrl'] = imagenUrl;
    if (rutaImagen != null) datos['imagenStoragePath'] = rutaImagen;

    try {
      await referenciaDocumento.set(datos);
    } catch (_) {
      if (nuevaRutaSubida != null) {
        await _almacenamiento.ref(nuevaRutaSubida).delete();
      }
      rethrow;
    }

    final rutaAnterior = existente.data()?['imagenStoragePath'] as String?;
    if (rutaAnterior != null && rutaAnterior != rutaImagen) {
      try {
        await _almacenamiento.ref(rutaAnterior).delete();
      } on FirebaseException {
        // El documento ya quedó actualizado; una imagen antigua huérfana no
        // debe revertir el guardado de los datos nuevos.
      }
    }
  }

  Future<void> eliminarLugar(LugarTuristico lugar) async {
    if (!await esAdministrador()) {
      throw StateError('La cuenta no tiene permisos de administrador.');
    }

    await _firestore.collection('lugares').doc(lugar.id).delete();
    final rutaImagen = lugar.imagenStoragePath;
    if (rutaImagen != null && rutaImagen.isNotEmpty) {
      try {
        await _almacenamiento.ref(rutaImagen).delete();
      } on FirebaseException catch (error) {
        if (error.code != 'object-not-found') rethrow;
      }
    }
  }

  String _tipoImagen(String nombre) {
    final extension = nombre.split('.').last.toLowerCase();
    if (extension == 'jpg' || extension == 'jpeg') return 'jpg';
    if (extension == 'png' || extension == 'webp') return extension;
    throw StateError('La imagen debe ser JPG, PNG o WebP.');
  }

  String _mimeType(String extension) => switch (extension) {
    'jpg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'application/octet-stream',
  };
}
