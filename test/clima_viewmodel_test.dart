import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:turisags/models/pronostico_dia.dart';
import 'package:turisags/repositories/clima_repository.dart';
import 'package:turisags/viewmodels/clima_viewmodel.dart';

class ClimaRepositoryFalso extends ClimaRepository {
  final Future<List<PronosticoDia>> Function() respuesta;

  ClimaRepositoryFalso(this.respuesta);

  @override
  Future<List<PronosticoDia>> obtenerPronostico({
    double latitud = 21.8853,
    double longitud = -102.2916,
  }) {
    return respuesta();
  }
}

void main() {
  test('El ViewModel carga el pronóstico correctamente', () async {
    final datos = [
      PronosticoDia(
        fecha: DateTime(2026, 10, 20),
        temperaturaMaxima: 25,
        temperaturaMinima: 12,
        probabilidadLluvia: 20,
      ),
    ];

    final repository = ClimaRepositoryFalso(() async => datos);

    final viewModel = ClimaViewModel(repository: repository);

    try {
      await viewModel.cargarClima();

      expect(viewModel.cargando, false);
      expect(viewModel.error, isNull);
      expect(viewModel.pronostico.length, 1);
      expect(viewModel.pronostico.first.temperaturaMaxima, 25);
    } finally {
      viewModel.dispose();
      repository.dispose();
    }
  });

  test('El ViewModel muestra un error de timeout', () async {
    final repository = ClimaRepositoryFalso(
      () async => throw TimeoutException('Tiempo agotado'),
    );

    final viewModel = ClimaViewModel(repository: repository);

    try {
      await viewModel.cargarClima();

      expect(viewModel.cargando, false);
      expect(viewModel.pronostico, isEmpty);
      expect(viewModel.error, contains('tardó demasiado'));
    } finally {
      viewModel.dispose();
      repository.dispose();
    }
  });

  test('El ViewModel detecta JSON incorrecto', () async {
    final repository = ClimaRepositoryFalso(
      () async => throw const FormatException('JSON inválido'),
    );

    final viewModel = ClimaViewModel(repository: repository);

    try {
      await viewModel.cargarClima();

      expect(viewModel.cargando, false);
      expect(viewModel.pronostico, isEmpty);
      expect(viewModel.error, contains('formato esperado'));
    } finally {
      viewModel.dispose();
      repository.dispose();
    }
  });

  test('El ViewModel indica que está cargando', () async {
    final solicitudPendiente = Completer<List<PronosticoDia>>();

    final repository = ClimaRepositoryFalso(() => solicitudPendiente.future);

    final viewModel = ClimaViewModel(repository: repository);

    try {
      final operacion = viewModel.cargarClima();

      expect(viewModel.cargando, true);
      expect(viewModel.error, isNull);

      solicitudPendiente.complete([]);

      await operacion;

      expect(viewModel.cargando, false);
      expect(viewModel.pronostico, isEmpty);
    } finally {
      viewModel.dispose();
      repository.dispose();
    }
  });
}
