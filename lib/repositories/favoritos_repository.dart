import 'package:shared_preferences/shared_preferences.dart';

class FavoritosRepository {
  static const _claveFavoritos = 'lugares_favoritos';
  final SharedPreferencesAsync _preferencias;

  FavoritosRepository({SharedPreferencesAsync? preferencias})
    : _preferencias = preferencias ?? SharedPreferencesAsync();

  Future<Set<String>> obtenerIdsFavoritos() async {
    final ids = await _preferencias.getStringList(_claveFavoritos);
    return (ids ?? <String>[]).toSet();
  }

  Future<void> guardarIdsFavoritos(Set<String> ids) async {
    await _preferencias.setStringList(_claveFavoritos, ids.toList());
  }
}
