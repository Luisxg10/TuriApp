import 'package:shared_preferences/shared_preferences.dart';

class FavoritosRepository {
  static const _claveFavoritos = 'lugares_favoritos';
  final SharedPreferencesAsync? preferencias;

  FavoritosRepository({this.preferencias});

  Future<Set<String>> obtenerIdsFavoritos() async {
    final almacenamiento = preferencias ?? SharedPreferencesAsync();
    final ids = await almacenamiento.getStringList(_claveFavoritos);
    return (ids ?? <String>[]).toSet();
  }

  Future<void> guardarIdsFavoritos(Set<String> ids) async {
    final almacenamiento = preferencias ?? SharedPreferencesAsync();
    await almacenamiento.setStringList(_claveFavoritos, ids.toList());
  }
}
