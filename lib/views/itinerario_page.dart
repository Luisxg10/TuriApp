import 'package:flutter/material.dart';

import '../app/dependencias.dart';
import '../models/lugar_turistico.dart';
import '../models/visita_planeada.dart';
import '../repositories/lugares_repository.dart';
import 'detalle_lugar_page.dart';

class ItinerarioPage extends StatelessWidget {
  const ItinerarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lugares = const LugaresRepository().obtenerLugares();
    final lugaresPorId = {for (final lugar in lugares) lugar.id: lugar};

    return Scaffold(
      appBar: AppBar(title: const Text('Mi itinerario')),
      body: AnimatedBuilder(
        animation: itinerarioViewModel,
        builder: (context, child) {
          if (itinerarioViewModel.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          final visitas = itinerarioViewModel.visitas
              .where((visita) => lugaresPorId.containsKey(visita.lugarId))
              .toList();

          if (visitas.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aún no tienes visitas planeadas. Abre un lugar y toca “Planear visita”.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: visitas.length,
            itemBuilder: (context, index) {
              final visita = visitas[index];
              final lugar = lugaresPorId[visita.lugarId]!;
              return _TarjetaVisita(visita: visita, lugar: lugar);
            },
          );
        },
      ),
    );
  }
}

class _TarjetaVisita extends StatelessWidget {
  final VisitaPlaneada visita;
  final LugarTuristico lugar;

  const _TarjetaVisita({required this.visita, required this.lugar});

  String _formatearFecha(DateTime fecha) {
    final dias = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    final meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${dias[fecha.weekday - 1]} ${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            lugar.imagenAsset,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(lugar.nombre),
        subtitle: Text(_formatearFecha(visita.fecha)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleLugarPage(lugar: lugar),
            ),
          );
        },
        trailing: IconButton(
          tooltip: 'Quitar del itinerario',
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final eliminada = await itinerarioViewModel.eliminarVisita(
              visita.id,
            );
            if (!eliminada && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se pudo quitar la visita.')),
              );
            }
          },
        ),
      ),
    );
  }
}
