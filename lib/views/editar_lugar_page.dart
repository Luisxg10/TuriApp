import 'package:flutter/material.dart';

import '../app/dependencias.dart';
import '../models/lugar_turistico.dart';
import '../repositories/administracion_catalogo_repository.dart';

class EditarLugarPage extends StatefulWidget {
  const EditarLugarPage({required this.repository, this.lugar, super.key});

  final AdministracionCatalogoRepository repository;
  final LugarTuristico? lugar;

  @override
  State<EditarLugarPage> createState() => _EditarLugarPageState();
}

class _EditarLugarPageState extends State<EditarLugarPage> {
  static const _imagenesDisponibles = [
    'assets/images/jardin_san_marcos.jpg',
    'assets/images/museo_muerte.jpg',
    'assets/images/plaza_patria.jpg',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  final _ubicacion = TextEditingController();
  final _costo = TextEditingController();
  final _horario = TextEditingController();
  final _fuente = TextEditingController();
  final _latitud = TextEditingController();
  final _longitud = TextEditingController();
  late String _categoria;
  late String _imagenAsset;
  bool _guardando = false;

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
    _imagenAsset = _imagenesDisponibles.contains(lugar?.imagenAsset)
        ? lugar!.imagenAsset!
        : _imagenesDisponibles.first;
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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final anterior = widget.lugar;
    final lugar = LugarTuristico(
      id: anterior?.id ?? '',
      nombre: _nombre.text.trim(),
      descripcion: _descripcion.text.trim(),
      ubicacion: _ubicacion.text.trim(),
      categoria: _categoria,
      costoOrientativo: _costo.text.trim(),
      horario: _horario.text.trim(),
      fechaActualizacion: DateTime.now(),
      fuenteUrl: _fuente.text.trim(),
      imagenAsset: _imagenAsset,
      latitud: double.parse(_latitud.text.trim()),
      longitud: double.parse(_longitud.text.trim()),
    );

    setState(() => _guardando = true);
    try {
      await widget.repository.guardarLugar(lugar);
      await lugaresRepository.cargarLugares(actualizar: true);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      final mensaje = error is StateError
          ? error.message.toString()
          : 'No se pudo guardar. Revisa tu conexión y tus permisos.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String? _obligatorio(String? valor) => valor == null || valor.trim().isEmpty
      ? 'Este campo es obligatorio.'
      : null;

  String? _validarNumero(String? valor, {required bool latitud}) {
    final numero = double.tryParse((valor ?? '').trim());
    if (numero == null) return 'Escribe un número válido.';
    if (latitud && (numero < -90 || numero > 90)) {
      return 'La latitud debe estar entre -90 y 90.';
    }
    if (!latitud && (numero < -180 || numero > 180)) {
      return 'La longitud debe estar entre -180 y 180.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final categorias = <String>{'Plazas', 'Jardines', 'Museos', _categoria};
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lugar == null ? 'Agregar lugar' : 'Editar lugar'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _imagenAsset,
              decoration: const InputDecoration(
                labelText: 'Imagen (asset local)',
                helperText: 'Una imagen nueva debe incluirse en la app y distribuirse en una actualización.',
                border: OutlineInputBorder(),
              ),
              items: _imagenesDisponibles
                  .map(
                    (ruta) => DropdownMenuItem(value: ruta, child: Text(ruta)),
                  )
                  .toList(),
              onChanged: _guardando
                  ? null
                  : (valor) {
                      if (valor != null) setState(() => _imagenAsset = valor);
                    },
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                _imagenAsset,
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 190,
                  child: Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
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
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
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
              'URL de fuente oficial (opcional)',
              keyboardType: TextInputType.url,
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) return null;
                final uri = Uri.tryParse(valor.trim());
                return uri == null || !uri.hasScheme || !uri.hasAuthority
                    ? 'Escribe una URL completa o deja el campo vacío.'
                    : null;
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
                    validator: (valor) => _validarNumero(valor, latitud: true),
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
                    validator: (valor) => _validarNumero(valor, latitud: false),
                  ),
                ),
              ],
            ),
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

  Widget _campo(
    TextEditingController controller,
    String etiqueta, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => Padding(
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
      validator: validator ?? _obligatorio,
    ),
  );
}
