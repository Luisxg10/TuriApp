import 'package:flutter/material.dart';

import '../app/dependencias.dart';
import '../models/lugar_turistico.dart';
import '../repositories/lugares_repository.dart';
import 'detalle_lugar_page.dart';

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis lugares favoritos')),
      body: FutureBuilder<CatalogoLugares>(
        future: lugaresRepository.cargarLugares(),
        builder: (context, catalogoSnapshot) {
          if (!catalogoSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lugares = catalogoSnapshot.data!.lugares;
          return AnimatedBuilder(
            animation: favoritosViewModel,
            builder: (context, child) {
              if (favoritosViewModel.cargando) {
                return const Center(child: CircularProgressIndicator());
              }

              final favoritos = lugares
                  .where((lugar) => favoritosViewModel.esFavorito(lugar.id))
                  .toList();

              if (favoritos.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Aún no tienes favoritos. Usa el corazón en el catálogo para guardar un lugar.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoritos.length,
                itemBuilder: (context, index) =>
                    _TarjetaFavorito(lugar: favoritos[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class _TarjetaFavorito extends StatelessWidget {
  final LugarTuristico lugar;

  const _TarjetaFavorito({required this.lugar});

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
        subtitle: Text('${lugar.categoria} · ${lugar.ubicacion}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleLugarPage(lugar: lugar),
            ),
          );
        },
        trailing: IconButton(
          tooltip: 'Quitar de favoritos',
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () async {
            final guardado = await favoritosViewModel.alternarFavorito(
              lugar.id,
            );
            if (!guardado && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se pudo actualizar favoritos.'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
