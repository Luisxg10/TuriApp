import 'dart:convert';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:turisags/repositories/clima_repository.dart';

void main() {
  final jsonCorrecto = jsonEncode({
    'daily': {
      'time': [
        '2026-10-20',
        '2026-10-21',
        '2026-10-22',
        '2026-10-23',
        '2026-10-24',
        '2026-10-25',
        '2026-10-26',
      ],
      'temperature_2m_max': [25.0, 26.0, 27.0, 24.0, 23.0, 25.0, 26.0],
      'temperature_2m_min': [12.0, 13.0, 14.0, 11.0, 10.0, 12.0, 13.0],
      'precipitation_probability_max': [10, 20, 30, 40, 50, 20, 10],
    },
  });

  test('Procesa correctamente siete días de JSON', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.host, 'api.open-meteo.com');
      expect(request.url.path, '/v1/forecast');
      expect(request.url.queryParameters['forecast_days'], '7');

      return http.Response(jsonCorrecto, 200);
    });

    final repository = ClimaRepository(client: client);

    try {
      final pronostico = await repository.obtenerPronostico();

      expect(pronostico.length, 7);
      expect(pronostico.first.temperaturaMaxima, 25.0);
      expect(pronostico.first.temperaturaMinima, 12.0);
      expect(pronostico.first.probabilidadLluvia, 10);
      expect(pronostico.last.probabilidadLluvia, 10);
    } finally {
      repository.dispose();
    }
  });

  test('Detecta un error HTTP 500', () async {
    final client = MockClient((request) async {
      return http.Response('Error del servidor', 500);
    });

    final repository = ClimaRepository(client: client);

    try {
      await expectLater(repository.obtenerPronostico(), throwsException);
    } finally {
      repository.dispose();
    }
  });

  test('Detecta JSON inválido', () async {
    final client = MockClient((request) async {
      return http.Response('Esto no es JSON', 200);
    });

    final repository = ClimaRepository(client: client);

    try {
      await expectLater(repository.obtenerPronostico(), throwsFormatException);
    } finally {
      repository.dispose();
    }
  });

  test('Detecta una respuesta con menos de siete días', () async {
    final jsonIncompleto = jsonEncode({
      'daily': {
        'time': ['2026-10-20'],
        'temperature_2m_max': [25.0],
        'temperature_2m_min': [12.0],
        'precipitation_probability_max': [10],
      },
    });

    final client = MockClient((request) async {
      return http.Response(jsonIncompleto, 200);
    });

    final repository = ClimaRepository(client: client);

    try {
      await expectLater(repository.obtenerPronostico(), throwsFormatException);
    } finally {
      repository.dispose();
    }
  });

  test('Detecta un error de conexión', () async {
    final client = MockClient((request) async {
      throw Exception('Sin conexión a internet');
    });

    final repository = ClimaRepository(client: client);

    try {
      await expectLater(repository.obtenerPronostico(), throwsException);
    } finally {
      repository.dispose();
    }
  });

  test('Detecta cuando la API tarda demasiado', () async {
    final solicitudPendiente = Completer<http.Response>();

    final client = MockClient((request) {
      return solicitudPendiente.future;
    });

    final repository = ClimaRepository(
      client: client,
      tiempoEspera: const Duration(milliseconds: 20),
    );

    try {
      await expectLater(
        repository.obtenerPronostico(),
        throwsA(isA<TimeoutException>()),
      );
    } finally {
      repository.dispose();
    }
  });
}
