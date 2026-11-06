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
  final String? imagenAsset;
  final String? imagenUrl;
  final String? imagenStoragePath;
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
    this.imagenAsset,
    this.imagenUrl,
    this.imagenStoragePath,
    required this.latitud,
    required this.longitud,
  });

  factory LugarTuristico.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return LugarTuristico(
      id: documentId,
      nombre: data['nombre'] as String,
      descripcion: data['descripcion'] as String,
      ubicacion: data['ubicacion'] as String,
      categoria: data['categoria'] as String,
      costoOrientativo: data['costoOrientativo'] as String,
      horario: data['horario'] as String,
      fechaActualizacion: DateTime.parse(data['fechaActualizacion'] as String),
      fuenteUrl: data['fuenteUrl'] as String,
      imagenAsset: data['imagenAsset'] as String?,
      imagenUrl: data['imagenUrl'] as String?,
      imagenStoragePath: data['imagenStoragePath'] as String?,
      latitud: (data['latitud'] as num).toDouble(),
      longitud: (data['longitud'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'ubicacion': ubicacion,
    'categoria': categoria,
    'costoOrientativo': costoOrientativo,
    'horario': horario,
    'fechaActualizacion': fechaActualizacion.toIso8601String().split('T').first,
    'fuenteUrl': fuenteUrl,
    if (imagenAsset != null) 'imagenAsset': imagenAsset,
    if (imagenUrl != null) 'imagenUrl': imagenUrl,
    if (imagenStoragePath != null) 'imagenStoragePath': imagenStoragePath,
    'latitud': latitud,
    'longitud': longitud,
  };
}
