import 'package:flutter/foundation.dart';

import '../repositories/favoritos_repository.dart';

class FavoritosViewModel extends ChangeNotifier {
  final FavoritosRepository repository;

  FavoritosViewModel({required this.repository});

  Set<String> idsFavoritos = {};
  bool cargando = true;

  bool esFavorito(String id) => idsFavoritos.contains(id);

  Future<void> cargarFavoritos() async {
    try {
      idsFavoritos = await repository.obtenerIdsFavoritos();
    } catch (_) {
      idsFavoritos = {};
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> alternarFavorito(String id) async {
    final nuevosIds = Set<String>.from(idsFavoritos);
    if (!nuevosIds.add(id)) {
      nuevosIds.remove(id);
    }

    try {
      await repository.guardarIdsFavoritos(nuevosIds);
      idsFavoritos = nuevosIds;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
