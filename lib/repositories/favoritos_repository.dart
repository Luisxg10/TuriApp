import 'package:shared_preferences/shared_preferences.dart';

class FavoritosRepository {
  static const _claveFavoritos = 'lugares_favoritos';
  final SharedPreferencesAsync? _preferencias;

  FavoritosRepository({SharedPreferencesAsync? preferencias})
    : _preferencias = preferencias;

  Future<Set<String>> obtenerIdsFavoritos() async {
    final preferencias = _preferencias ?? SharedPreferencesAsync();
    final ids = await preferencias.getStringList(_claveFavoritos);
    return (ids ?? <String>[]).toSet();
  }

  Future<void> guardarIdsFavoritos(Set<String> ids) async {
    final preferencias = _preferencias ?? SharedPreferencesAsync();
    await preferencias.setStringList(_claveFavoritos, ids.toList());
  }
}
