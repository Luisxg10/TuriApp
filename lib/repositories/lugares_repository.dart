import '../models/lugar_turistico.dart';

class LugaresRepository {
  const LugaresRepository();

  List<LugarTuristico> obtenerLugares() {
    return const [
      LugarTuristico(
        id: '1',
        nombre: 'Plaza de la Patria',
        descripcion: 'Espacio histórico en el centro de Aguascalientes.',
        ubicacion: 'Centro de Aguascalientes',
        categoria: 'Plazas',
        latitud: 21.963585041386942,
        longitud: -102.3441541226031,
      ),
      LugarTuristico(
        id: '2',
        nombre: 'Jardín de San Marcos',
        descripcion: 'Uno de los jardines más emblemáticos de la ciudad.',
        ubicacion: 'Barrio de San Marcos',
        categoria: 'Jardines',
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
        latitud: 21.883948329694125,
        longitud: -102.29546186200008,
      ),
    ];
  }
}
