import 'package:flutter/material.dart';

import '../repositories/lugares_repository.dart';
import '../viewmodels/lugares_viewmodel.dart';
import 'detalle_lugar_page.dart';

class LugaresPage extends StatefulWidget {
  const LugaresPage({super.key});

  @override
  State<LugaresPage> createState() => _LugaresPageState();
}

class _LugaresPageState extends State<LugaresPage> {
  late final LugaresViewModel viewModel;
  final TextEditingController controladorBusqueda = TextEditingController();
  String categoriaSeleccionada = 'Todos';

  @override
  void initState() {
    super.initState();
    viewModel = LugaresViewModel(repository: const LugaresRepository());
  }

  @override
  void dispose() {
    controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categorias = viewModel.obtenerCategorias();
    final lugares = viewModel.buscarYFiltrar(
      texto: controladorBusqueda.text,
      categoria: categoriaSeleccionada,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Lugares turísticos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: controladorBusqueda,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Buscar lugares',
                hintText: 'Nombre, descripción o ubicación',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controladorBusqueda.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: () {
                          controladorBusqueda.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: categorias.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                return ChoiceChip(
                  label: Text(categoria),
                  selected: categoriaSeleccionada == categoria,
                  onSelected: (_) => setState(() {
                    categoriaSeleccionada = categoria;
                  }),
                );
              },
            ),
          ),
          Expanded(
            child: lugares.isEmpty
                ? const Center(
                    child: Text('No se encontraron lugares con esos criterios.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: lugares.length,
                    itemBuilder: (context, index) {
                      final lugar = lugares[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              lugar.imagenAsset,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              semanticLabel: 'Ilustración de ${lugar.nombre}',
                            ),
                          ),
                          title: Text(lugar.nombre),
                          subtitle: Text(
                            '${lugar.categoria} · ${lugar.descripcion}\n${lugar.ubicacion}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetalleLugarPage(lugar: lugar),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
