import '../repositories/favoritos_repository.dart';
import '../viewmodels/favoritos_viewmodel.dart';

final favoritosViewModel = FavoritosViewModel(
  repository: FavoritosRepository(),
);
