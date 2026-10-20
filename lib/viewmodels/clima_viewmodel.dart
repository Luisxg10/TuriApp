import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/pronostico_dia.dart';
import '../repositories/clima_repository.dart';

class ClimaViewModel extends ChangeNotifier {
  final ClimaRepository repository;

  ClimaViewModel({required this.repository});

  bool cargando = false;
  String? error;
  List<PronosticoDia> pronostico = [];

  Future<void> cargarClima() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      pronostico = await repository.obtenerPronostico();
    } on TimeoutException {
      pronostico = [];
      error =
          'La consulta tardó demasiado. '
          'Inténtalo nuevamente.';
    } on FormatException {
      pronostico = [];
      error =
          'Los datos del clima no tienen '
          'el formato esperado.';
    } catch (e) {
      pronostico = [];
      error =
          'No se pudo obtener el clima. '
          'Revisa tu conexión e inténtalo de nuevo.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
