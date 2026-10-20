import 'package:flutter/material.dart';

import '../repositories/clima_repository.dart';
import '../viewmodels/clima_viewmodel.dart';

class ClimaPage extends StatefulWidget {
  const ClimaPage({super.key});

  @override
  State<ClimaPage> createState() => _ClimaPageState();
}

class _ClimaPageState extends State<ClimaPage> {
  late final ClimaViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = ClimaViewModel(repository: ClimaRepository());

    viewModel.cargarClima();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clima de Aguascalientes')),
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
                    Text(viewModel.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: viewModel.cargarClima,
                      child: const Text('Reintentar'),
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
            onRefresh: viewModel.cargarClima,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.pronostico.length,
              itemBuilder: (context, index) {
                final dia = viewModel.pronostico[index];

                final fecha =
                    '${dia.fecha.day}/${dia.fecha.month}/'
                    '${dia.fecha.year}';

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.wb_sunny, color: Colors.orange),
                    title: Text(fecha),
                    subtitle: Text(
                      'Máxima: '
                      '${dia.temperaturaMaxima.toStringAsFixed(1)} °C\n'
                      'Mínima: '
                      '${dia.temperaturaMinima.toStringAsFixed(1)} °C\n'
                      'Probabilidad de lluvia: '
                      '${dia.probabilidadLluvia} %',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
