import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/lugar_turistico.dart';

class CatalogoLugares {
  final List<LugarTuristico> lugares;
  final bool esLocal;
  final String? mensaje;

  const CatalogoLugares({
    required this.lugares,
    required this.esLocal,
    this.mensaje,
  });
}

class LugaresRepository {
  LugaresRepository({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  Future<CatalogoLugares>? _cargaEnCurso;

  Future<CatalogoLugares> cargarLugares({bool actualizar = false}) {
    if (actualizar || _cargaEnCurso == null) {
      _cargaEnCurso = _cargarDesdeFirestore();
    }
    return _cargaEnCurso!;
  }

  Future<CatalogoLugares> _cargarDesdeFirestore() async {
    if (Firebase.apps.isEmpty && _firestore == null) {
      return CatalogoLugares(
        lugares: obtenerLugaresLocales(),
        esLocal: true,
        mensaje: 'Se muestra el catálogo local de ejemplo.',
      );
    }

    try {
      final baseDeDatos = _firestore ?? FirebaseFirestore.instance;
      final documentos = await baseDeDatos
          .collection('lugares')
          .orderBy('nombre')
          .get();

      if (documentos.docs.isEmpty) {
        return CatalogoLugares(
          lugares: obtenerLugaresLocales(),
          esLocal: true,
          mensaje: 'El catálogo de Firestore está vacío. Se muestran los datos de ejemplo.',
        );
      }

      final lugares = documentos.docs
          .map(
            (documento) =>
                LugarTuristico.fromFirestore(documento.id, documento.data()),
          )
          .toList();
      return CatalogoLugares(lugares: lugares, esLocal: false);
    } catch (_) {
      return CatalogoLugares(
        lugares: obtenerLugaresLocales(),
        esLocal: true,
        mensaje: 'No se pudo consultar Firestore. Se muestra el catálogo local de ejemplo.',
      );
    }
  }

  List<LugarTuristico> obtenerLugaresLocales() {
    return [
      LugarTuristico(
        id: '1',
        nombre: 'Plaza de la Patria',
        descripcion: 'Espacio histórico en el centro de Aguascalientes.',
        ubicacion: 'Centro de Aguascalientes',
        categoria: 'Plazas',
        costoOrientativo: 'Gratuito; puede variar durante eventos.',
        horario: 'Espacio público. La Exedra se reporta abierta todos los días, 24 horas.',
        fechaActualizacion: DateTime(2026, 11, 5),
        fuenteUrl: 'https://www.ags.gob.mx/turismo/conocemas/exedra/index.html',
        imagenAsset: 'assets/images/plaza_patria.jpg',
        latitud: 21.963585041386942,
        longitud: -102.3441541226031,
      ),
      LugarTuristico(
        id: '2',
        nombre: 'Jardín de San Marcos',
        descripcion: 'Uno de los jardines más emblemáticos de la ciudad.',
        ubicacion: 'Barrio de San Marcos',
        categoria: 'Jardines',
        costoOrientativo: 'Gratuito.',
        horario: 'Lunes a domingo, de 05:00 a 22:00.',
        fechaActualizacion: DateTime(2026, 11, 5),
        fuenteUrl: 'https://www.ags.gob.mx/turismo/conocemas/jardinsanmarcos/index.html',
        imagenAsset: 'assets/images/jardin_san_marcos.jpg',
        latitud: 21.87971010830155,
        longitud: -102.30279112212934,
      ),
      LugarTuristico(
        id: '3',
        nombre: 'Museo Nacional de la Muerte',
        descripcion:
            'Museo dedicado a las expresiones culturales de la muerte.',
        ubicacion: 'Centro de Aguascalientes',
        categoria: 'Museos',
        costoOrientativo: 'Consulta el precio vigente con el museo.',
        horario: 'Martes a domingo, de 10:00 a 18:00.',
        fechaActualizacion: DateTime(2026, 11, 5),
        fuenteUrl: 'https://www.ags.gob.mx/turismo/conocemas/museodelamuerte/index.html',
        imagenAsset: 'assets/images/museo_muerte.jpg',
        latitud: 21.883948329694125,
        longitud: -102.29546186200008,
      ),
    ];
  }
}
