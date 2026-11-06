class VisitaPlaneada {
  final String lugarId;
  final DateTime fecha;

  const VisitaPlaneada({required this.lugarId, required this.fecha});

  String get id => '$lugarId|${fecha.toIso8601String().split('T').first}';

  Map<String, dynamic> toJson() => {
    'lugarId': lugarId,
    'fecha': fecha.toIso8601String().split('T').first,
  };

  factory VisitaPlaneada.fromJson(Map<String, dynamic> json) {
    return VisitaPlaneada(
      lugarId: json['lugarId'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
    );
  }
}
