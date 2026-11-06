import 'package:flutter/material.dart';

import '../app/dependencias.dart';
import 'clima_page.dart';
import '../models/lugar_turistico.dart';
import '../widgets/lugar_imagen.dart';

class DetalleLugarPage extends StatelessWidget {
  final LugarTuristico lugar;

  const DetalleLugarPage({super.key, required this.lugar});

  String formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del lugar')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LugarImagen(
                  lugar: lugar,
                  width: double.infinity,
                  height: 210,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                lugar.nombre,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Descripción',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(lugar.descripcion, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 24),

              const Text(
                'Ubicación',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF008577)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lugar.ubicacion,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _SeccionDetalle(
                titulo: 'Categoría',
                contenido: lugar.categoria,
                icono: Icons.category,
              ),
              _SeccionDetalle(
                titulo: 'Costo orientativo',
                contenido: lugar.costoOrientativo,
                icono: Icons.payments_outlined,
              ),
              _SeccionDetalle(
                titulo: 'Horario',
                contenido: lugar.horario,
                icono: Icons.schedule,
              ),
              _SeccionDetalle(
                titulo: 'Información revisada',
                contenido: formatearFecha(lugar.fechaActualizacion),
                icono: Icons.update,
              ),
              const Text(
                'Fuente oficial',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SelectableText(lugar.fuenteUrl),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final hoy = DateTime.now();
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: hoy,
                      firstDate: hoy,
                      lastDate: DateTime(2100),
                      helpText: 'Selecciona el día de tu visita',
                      cancelText: 'Cancelar',
                      confirmText: 'Guardar',
                    );
                    if (fecha == null || !context.mounted) return;

                    final guardada = await itinerarioViewModel.programarVisita(
                      lugar.id,
                      fecha,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          guardada
                              ? 'Visita agregada a tu itinerario.'
                              : 'No se pudo guardar la visita.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.event_available),
                  label: const Text('Planear visita'),
                ),
              ),

              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClimaPage(
                          nombreLugar: lugar.nombre,
                          latitud: lugar.latitud,
                          longitud: lugar.longitud,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cloud),
                  label: const Text('Consultar clima del lugar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeccionDetalle extends StatelessWidget {
  final String titulo;
  final String contenido;
  final IconData icono;

  const _SeccionDetalle({
    required this.titulo,
    required this.contenido,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: const Color(0xFF008577)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(contenido),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
