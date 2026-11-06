import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app/dependencias.dart';
import '../models/lugar_turistico.dart';
import '../repositories/administracion_catalogo_repository.dart';
import '../widgets/lugar_imagen.dart';

class EditarLugarPage extends StatefulWidget {
  const EditarLugarPage({required this.repository, this.lugar, super.key});

  final AdministracionCatalogoRepository repository;
  final LugarTuristico? lugar;

  @override
  State<EditarLugarPage> createState() => _EditarLugarPageState();
}

class _EditarLugarPageState extends State<EditarLugarPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  final _ubicacion = TextEditingController();
  final _costo = TextEditingController();
  final _horario = TextEditingController();
  final _fuente = TextEditingController();
  final _latitud = TextEditingController();
  final _longitud = TextEditingController();
  final _selectorImagen = ImagePicker();

  late String _categoria;
  XFile? _imagenSeleccionada;
  Uint8List? _bytesImagen;
  bool _guardando = false;
  double _progreso = 0;

  @override
  void initState() {
    super.initState();
    final lugar = widget.lugar;
    _nombre.text = lugar?.nombre ?? '';
    _descripcion.text = lugar?.descripcion ?? '';
    _ubicacion.text = lugar?.ubicacion ?? '';
    _costo.text = lugar?.costoOrientativo ?? '';
    _horario.text = lugar?.horario ?? '';
    _fuente.text = lugar?.fuenteUrl ?? '';
    _latitud.text = lugar?.latitud.toString() ?? '';
    _longitud.text = lugar?.longitud.toString() ?? '';
    _categoria = lugar?.categoria ?? 'Plazas';
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _ubicacion.dispose();
    _costo.dispose();
    _horario.dispose();
    _fuente.dispose();
    _latitud.dispose();
    _longitud.dispose();
    super.dispose();
  }

  Future<void> _elegirImagen() async {
    try {
      final imagen = await _selectorImagen.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        imageQuality: 85,
      );
      if (imagen == null) return;
      final bytes = await imagen.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        _mostrarMensaje('La imagen debe pesar menos de 5 MB.');
        return;
      }
      if (!mounted) return;
      setState(() {
        _imagenSeleccionada = imagen;
        _bytesImagen = bytes;
      });
    } catch (_) {
      _mostrarMensaje('No se pudo abrir la galería de imágenes.');
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.lugar == null && _imagenSeleccionada == null) {
      _mostrarMensaje('Selecciona una imagen para el nuevo lugar.');
      return;
    }

    final lugarAnterior = widget.lugar;
    final latitud = double.parse(_latitud.text.trim());
    final longitud = double.parse(_longitud.text.trim());
    final lugar = LugarTuristico(
      id: lugarAnterior?.id ?? '',
      nombre: _nombre.text.trim(),
      descripcion: _descripcion.text.trim(),
      ubicacion: _ubicacion.text.trim(),
      categoria: _categoria,
      costoOrientativo: _costo.text.trim(),
      horario: _horario.text.trim(),
      fechaActualizacion: DateTime.now(),
      fuenteUrl: _fuente.text.trim(),
      imagenAsset: lugarAnterior?.imagenAsset,
      imagenUrl: lugarAnterior?.imagenUrl,
      imagenStoragePath: lugarAnterior?.imagenStoragePath,
      latitud: latitud,
      longitud: longitud,
    );

    setState(() {
      _guardando = true;
      _progreso = 0;
    });
    try {
      await widget.repository.guardarLugar(
        lugar: lugar,
        imagenNueva: _imagenSeleccionada,
        alCambiarProgreso: (progreso) {
          if (mounted) setState(() => _progreso = progreso);
        },
      );
      await lugaresRepository.cargarLugares(actualizar: true);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      _mostrarMensaje(_mensajeDeError(error));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String _mensajeDeError(Object error) {
    if (error is StateError) return error.message.toString();
    return 'No se pudo guardar el lugar. Revisa tu conexión y tus permisos.';
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  String? _validarObligatorio(String? valor) =>
      valor == null || valor.trim().isEmpty
      ? 'Este campo es obligatorio.'
      : null;

  String? _validarNumero(String? valor, {required bool esLatitud}) {
    final numero = double.tryParse((valor ?? '').trim());
    if (numero == null) return 'Escribe un número válido.';
    if (esLatitud && (numero < -90 || numero > 90)) {
      return 'La latitud debe estar entre -90 y 90.';
    }
    if (!esLatitud && (numero < -180 || numero > 180)) {
      return 'La longitud debe estar entre -180 y 180.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final categorias = <String>{
      'Plazas',
      'Jardines',
      'Museos',
      _categoria,
    }.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lugar == null ? 'Agregar lugar' : 'Editar lugar'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _construirVistaPrevia(),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _guardando ? null : _elegirImagen,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                _imagenSeleccionada == null
                    ? 'Elegir imagen de la galería'
                    : 'Cambiar imagen',
              ),
            ),
            if (widget.lugar != null && _imagenSeleccionada == null)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Si no eliges otra, se conserva la imagen actual.'),
              ),
            const SizedBox(height: 20),
            _campo(_nombre, 'Nombre'),
            _campo(_descripcion, 'Descripción', maxLines: 3),
            _campo(_ubicacion, 'Ubicación'),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: categorias
                  .map(
                    (categoria) => DropdownMenuItem(
                      value: categoria,
                      child: Text(categoria),
                    ),
                  )
                  .toList(),
              onChanged: _guardando
                  ? null
                  : (valor) {
                      if (valor != null) setState(() => _categoria = valor);
                    },
            ),
            const SizedBox(height: 16),
            _campo(_costo, 'Costo orientativo'),
            _campo(_horario, 'Horario', maxLines: 2),
            _campo(
              _fuente,
              'URL de la fuente',
              keyboardType: TextInputType.url,
              validator: (valor) {
                final error = _validarObligatorio(valor);
                if (error != null) return error;
                final uri = Uri.tryParse(valor!.trim());
                if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                  return 'Escribe una URL completa.';
                }
                return null;
              },
            ),
            Row(
              children: [
                Expanded(
                  child: _campo(
                    _latitud,
                    'Latitud',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (valor) =>
                        _validarNumero(valor, esLatitud: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _campo(
                    _longitud,
                    'Longitud',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (valor) =>
                        _validarNumero(valor, esLatitud: false),
                  ),
                ),
              ],
            ),
            if (_guardando) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _progreso == 0 ? null : _progreso),
              const SizedBox(height: 8),
              const Text('Subiendo imagen y guardando lugar…'),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save_outlined),
              label: Text(_guardando ? 'Guardando…' : 'Guardar lugar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirVistaPrevia() {
    final bytes = _bytesImagen;
    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bytes, height: 190, fit: BoxFit.cover),
      );
    }
    final lugar = widget.lugar;
    if (lugar != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LugarImagen(lugar: lugar, height: 190),
      );
    }
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.add_photo_alternate_outlined, size: 48),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String etiqueta, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: !_guardando,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? _validarObligatorio,
      ),
    );
  }
}
