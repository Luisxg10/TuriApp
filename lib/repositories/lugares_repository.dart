import '../models/lugar_turistico.dart';

class LugaresRepository {
  const LugaresRepository();

  List<LugarTuristico> obtenerLugares() {
    return [
      LugarTuristico(
        id: '1',
        nombre: 'Plaza de la Patria',
        descripcion: 'Espacio histórico en el centro de Aguascalientes.',
        ubicacion: 'Centro de Aguascalientes',
        categoria: 'Plazas',
        costoOrientativo: 'Gratuito; puede variar durante eventos.',
        horario:
            'Espacio público. La Exedra se reporta abierta todos los días, 24 horas.',
        fechaActualizacion: DateTime(2026, 11, 5),
        fuenteUrl:
            'https://www.ags.gob.mx/turismo/conocemas/exedra/index.html',
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
        fuenteUrl:
            'https://www.ags.gob.mx/turismo/conocemas/jardinsanmarcos/index.html',
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
        fuenteUrl:
            'https://www.ags.gob.mx/turismo/conocemas/museodelamuerte/index.html',
        latitud: 21.883948329694125,
        longitud: -102.29546186200008,
      ),
    ];
  }
}
