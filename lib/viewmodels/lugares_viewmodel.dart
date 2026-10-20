import '../models/lugar_turistico.dart';
import '../repositories/lugares_repository.dart';

class LugaresViewModel {
  final LugaresRepository repository;

  LugaresViewModel({required this.repository});

  List<LugarTuristico> obtenerLugares() {
    return repository.obtenerLugares();
  }
}
