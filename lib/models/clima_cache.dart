import 'pronostico_dia.dart';
import 'temperatura_actual.dart';

class ClimaCache {
  final List<PronosticoDia> pronostico;
  final TemperaturaActual temperaturaActual;
  final DateTime actualizadoEn;

  const ClimaCache({
    required this.pronostico,
    required this.temperaturaActual,
    required this.actualizadoEn,
  });
}
