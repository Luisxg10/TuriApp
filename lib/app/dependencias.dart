import '../repositories/favoritos_repository.dart';
import '../repositories/itinerario_repository.dart';
import '../viewmodels/favoritos_viewmodel.dart';
import '../viewmodels/itinerario_viewmodel.dart';

final favoritosViewModel = FavoritosViewModel(
  repository: FavoritosRepository(),
);

final itinerarioViewModel = ItinerarioViewModel(
  repository: ItinerarioRepository(),
);
