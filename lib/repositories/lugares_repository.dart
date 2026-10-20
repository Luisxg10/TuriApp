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
      ),
      LugarTuristico(
        id: '2',
        nombre: 'Jardín de San Marcos',
        descripcion: 'Uno de los jardines más emblemáticos de la ciudad.',
        ubicacion: 'Barrio de San Marcos',
      ),
      LugarTuristico(
        id: '3',
        nombre: 'Museo Nacional de la Muerte',
        descripcion:
            'Museo dedicado a las expresiones culturales de la muerte.',
        ubicacion: 'Centro de Aguascalientes',
      ),
    ];
  }
}
