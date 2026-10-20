import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/temperatura_actual.dart';
import '../models/clima_cache.dart';
import '../models/pronostico_dia.dart';

class ClimaRepository {
  final http.Client _client;
  final Duration tiempoEspera;
  final Map<String, ClimaCache> _cache = {};
  final Duration duracionCache = const Duration(minutes: 15);
  DateTime? ultimaActualizacion;
  TemperaturaActual? temperaturaActual;

  ClimaRepository({
    http.Client? client,
    this.tiempoEspera = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  Future<List<PronosticoDia>> obtenerPronostico({
    double latitud = 21.8853,
    double longitud = -102.2916,
  }) async {
    final clave = '$latitud,$longitud';
    final ahora = DateTime.now();
    final datosGuardados = _cache[clave];
    if (datosGuardados != null &&
        ahora.difference(datosGuardados.actualizadoEn) < duracionCache) {
      ultimaActualizacion = datosGuardados.actualizadoEn;
      temperaturaActual = datosGuardados.temperaturaActual;
      return datosGuardados.pronostico;
    }
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitud.toString(),
      'longitude': longitud.toString(),
      'daily':
          'temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max',
      'current': 'temperature_2m',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final respuesta = await _client.get(uri).timeout(tiempoEspera);

    if (respuesta.statusCode != 200) {
      throw Exception('Error HTTP: ${respuesta.statusCode}');
    }

    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;

    final currentDatos = datos['current'];

    if (currentDatos is! Map<String, dynamic>) {
      throw const FormatException(
        'La respuesta no contiene datos actuales válidos.',
      );
    }

    final current = currentDatos;

    final nuevaTemperaturaActual = TemperaturaActual(
      grados: (current['temperature_2m'] as num).toDouble(),
      fechaHora: DateTime.parse(current['time'] as String),
    );
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

    final pronostico = List.generate(7, (index) {
      return PronosticoDia(
        fecha: DateTime.parse(fechas[index] as String),
        temperaturaMaxima: (maximas[index] as num).toDouble(),
        temperaturaMinima: (minimas[index] as num).toDouble(),
        probabilidadLluvia: (lluvias[index] as num).toInt(),
      );
    });

    final actualizadoEn = DateTime.now();
    _cache[clave] = ClimaCache(
      pronostico: pronostico,
      temperaturaActual: nuevaTemperaturaActual,
      actualizadoEn: actualizadoEn,
    );
    ultimaActualizacion = actualizadoEn;
    temperaturaActual = nuevaTemperaturaActual;
    return pronostico;
  }

  void dispose() {
    _client.close();
  }
}
