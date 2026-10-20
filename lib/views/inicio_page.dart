import 'package:flutter/material.dart';

import 'clima_page.dart';
import 'lugares_page.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TurisAGS'),
        centerTitle: true,
        backgroundColor: const Color(0xFF008577),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.travel_explore,
                size: 100,
                color: Color(0xFF008577),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bienvenido a TurisAGS',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Descubre los mejores lugares turísticos '
                'de Aguascalientes.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LugaresPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.place),
                label: const Text('Explorar lugares'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ClimaPage()),
                  );
                },
                icon: const Icon(Icons.cloud),
                label: const Text('Consultar clima'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
