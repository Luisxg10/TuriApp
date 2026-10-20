import 'package:flutter/material.dart';

import '../repositories/lugares_repository.dart';
import '../viewmodels/lugares_viewmodel.dart';
import 'detalle_lugar_page.dart';

class LugaresPage extends StatelessWidget {
  const LugaresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = LugaresViewModel(repository: const LugaresRepository());

    final lugares = viewModel.obtenerLugares();

    return Scaffold(
      appBar: AppBar(title: const Text('Lugares turísticos')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lugares.length,
        itemBuilder: (context, index) {
          final lugar = lugares[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.place, color: Color(0xFF008577)),
              title: Text(lugar.nombre),
              subtitle: Text('${lugar.descripcion}\n${lugar.ubicacion}'),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleLugarPage(lugar: lugar),
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
