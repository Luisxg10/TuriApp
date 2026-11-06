import 'package:flutter/material.dart';

import '../app/dependencias.dart';
import '../models/lugar_turistico.dart';
import '../repositories/administracion_catalogo_repository.dart';
import '../widgets/lugar_imagen.dart';
import 'editar_lugar_page.dart';

class AdministracionCatalogoPage extends StatefulWidget {
  const AdministracionCatalogoPage({super.key});

  @override
  State<AdministracionCatalogoPage> createState() =>
      _AdministracionCatalogoPageState();
}

class _AdministracionCatalogoPageState
    extends State<AdministracionCatalogoPage> {
  final _repository = AdministracionCatalogoRepository();
  late final Future<bool> _permiso;
  Future<List<LugarTuristico>>? _lugares;

  @override
  void initState() {
    super.initState();
    _permiso = _repository.esAdministrador();
  }

  Future<void> _abrirFormulario([LugarTuristico? lugar]) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarLugarPage(repository: _repository, lugar: lugar),
      ),
    );
    if (guardado == true && mounted) {
      setState(() => _lugares = _repository.obtenerLugares());
    }
  }

  Future<void> _eliminar(LugarTuristico lugar) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar lugar'),
        content: Text('¿Quieres eliminar “${lugar.nombre}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _repository.eliminarLugar(lugar);
      await lugaresRepository.cargarLugares(actualizar: true);
      if (!mounted) return;
      setState(() => _lugares = _repository.obtenerLugares());
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lugar eliminado.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el lugar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar lugares')),
      body: FutureBuilder<bool>(
        future: _permiso,
        builder: (context, permisoSnapshot) {
          if (permisoSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (permisoSnapshot.data != true) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Esta cuenta no tiene permisos para administrar el catálogo.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          _lugares ??= _repository.obtenerLugares();
          return FutureBuilder<List<LugarTuristico>>(
            future: _lugares,
            builder: (context, lugaresSnapshot) {
              if (lugaresSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (lugaresSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No se pudo cargar el catálogo: ${lugaresSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final lugares = lugaresSnapshot.data ?? [];
              if (lugares.isEmpty) {
                return const Center(
                  child: Text('Todavía no hay lugares. Agrega el primero.'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() => _lugares = _repository.obtenerLugares());
                  await _lugares;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lugares.length,
                  itemBuilder: (context, index) {
                    final lugar = lugares[index];
                    return Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LugarImagen(
                            lugar: lugar,
                            width: 60,
                            height: 60,
                          ),
                        ),
                        title: Text(lugar.nombre),
                        subtitle: Text(
                          '${lugar.categoria} · ${lugar.ubicacion}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (accion) {
                            if (accion == 'editar') {
                              _abrirFormulario(lugar);
                            } else if (accion == 'eliminar') {
                              _eliminar(lugar);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            PopupMenuItem(
                              value: 'eliminar',
                              child: Text('Eliminar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: _permiso,
        builder: (context, snapshot) {
          if (snapshot.data != true) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: _abrirFormulario,
            icon: const Icon(Icons.add),
            label: const Text('Agregar lugar'),
          );
        },
      ),
    );
  }
}
