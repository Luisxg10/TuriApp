class LugarTuristico {
  final String id;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  final String categoria;
  final String costoOrientativo;
  final String horario;
  final DateTime fechaActualizacion;
  final String fuenteUrl;
  final double latitud;
  final double longitud;

  const LugarTuristico({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.categoria,
    required this.costoOrientativo,
    required this.horario,
    required this.fechaActualizacion,
    required this.fuenteUrl,
    required this.latitud,
    required this.longitud,
  });
}
