import 'package:flutter/material.dart';

import '../models/pronostico_dia.dart';
import '../repositories/clima_repository.dart';
import '../viewmodels/clima_viewmodel.dart';

class ClimaPage extends StatefulWidget {
  final String nombreLugar;
  final double latitud;
  final double longitud;

  const ClimaPage({
    super.key,
    this.nombreLugar = 'Aguascalientes',
    this.latitud = 21.8853,
    this.longitud = -102.2916,
  });

  @override
  State<ClimaPage> createState() => _ClimaPageState();
}

class _ClimaPageState extends State<ClimaPage> {
  late final ClimaRepository repository;
  late final ClimaViewModel viewModel;

  @override
  void initState() {
    super.initState();

    repository = ClimaRepository();
    viewModel = ClimaViewModel(repository: repository);

    viewModel.cargarClima(latitud: widget.latitud, longitud: widget.longitud);
  }

  @override
  void dispose() {
    viewModel.dispose();
    repository.dispose();
    super.dispose();
  }

  String formatearFecha(DateTime fecha) {
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    const meses = [
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

    return '${dias[fecha.weekday - 1]} '
        '${fecha.day} de ${meses[fecha.month - 1]}';
  }

  Widget construirTarjeta(PronosticoDia dia) {
    final lluviaAlta = dia.probabilidadLluvia >= 60;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF008577)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formatearFecha(dia.fecha),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.thermostat, color: Colors.deepOrange),
                      const Text('Máxima'),
                      Text(
                        '${dia.temperaturaMaxima.toStringAsFixed(1)} °C',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.ac_unit, color: Colors.blue),
                      const Text('Mínima'),
                      Text(
                        '${dia.temperaturaMinima.toStringAsFixed(1)} °C',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Probabilidad máxima de lluvia: '
                    '${dia.probabilidadLluvia} %',
                  ),
                ),
              ],
            ),
            if (lluviaAlta) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Probabilidad alta de lluvia. '
                      'Considera actividades bajo techo.',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clima: ${widget.nombreLugar}')),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, child) {
          if (viewModel.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 64),
                    const SizedBox(height: 16),
                    Text(viewModel.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        viewModel.cargarClima(
                          latitud: widget.latitud,
                          longitud: widget.longitud,
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (viewModel.pronostico.isEmpty) {
            return const Center(child: Text('No hay pronósticos disponibles.'));
          }

          return RefreshIndicator(
            onRefresh: () {
              return viewModel.cargarClima(
                latitud: widget.latitud,
                longitud: widget.longitud,
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Pronóstico de los próximos 7 días',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Consulta la temperatura y la '
                  'probabilidad de lluvia para '
                  'planear tus actividades.',
                ),
                const SizedBox(height: 20),
                for (final dia in viewModel.pronostico) construirTarjeta(dia),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Datos meteorológicos: Open-Meteo\n'
                    'https://open-meteo.com/',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
