import 'package:flutter/material.dart';

import 'clima_page.dart';
import '../models/lugar_turistico.dart';

class DetalleLugarPage extends StatelessWidget {
  final LugarTuristico lugar;

  const DetalleLugarPage({super.key, required this.lugar});

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
              const Center(
                child: Icon(
                  Icons.landscape,
                  size: 120,
                  color: Color(0xFF008577),
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
