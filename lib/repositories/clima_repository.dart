import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pronostico_dia.dart';

class ClimaRepository {
  final http.Client _client;
  final Duration tiempoEspera;

  ClimaRepository({
    http.Client? client,
    this.tiempoEspera = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  Future<List<PronosticoDia>> obtenerPronostico({
    double latitud = 21.8853,
    double longitud = -102.2916,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitud.toString(),
      'longitude': longitud.toString(),
      'daily':
          'temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final respuesta = await _client.get(uri).timeout(tiempoEspera);

    if (respuesta.statusCode != 200) {
      throw Exception('Error HTTP: ${respuesta.statusCode}');
    }

    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;

    final daily = datos['daily'] as Map<String, dynamic>;

    final fechas = daily['time'] as List;
    final maximas = daily['temperature_2m_max'] as List;
    final minimas = daily['temperature_2m_min'] as List;
    final lluvias = daily['precipitation_probability_max'] as List;

    if (fechas.length != 7 ||
        maximas.length != 7 ||
        minimas.length != 7 ||
        lluvias.length != 7) {
      throw const FormatException(
        'El pronóstico no contiene siete días completos.',
      );
    }

    return List.generate(7, (index) {
      return PronosticoDia(
        fecha: DateTime.parse(fechas[index] as String),
        temperaturaMaxima: (maximas[index] as num).toDouble(),
        temperaturaMinima: (minimas[index] as num).toDouble(),
        probabilidadLluvia: (lluvias[index] as num).toInt(),
      );
    });
  }

  void dispose() {
    _client.close();
  }
}
