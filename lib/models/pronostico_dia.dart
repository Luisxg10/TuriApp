class PronosticoDia {
  final DateTime fecha;
  final double temperaturaMaxima;
  final double temperaturaMinima;
  final int probabilidadLluvia;

  const PronosticoDia({
    required this.fecha,
    required this.temperaturaMaxima,
    required this.temperaturaMinima,
    required this.probabilidadLluvia,
  });
}
