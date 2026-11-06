import 'package:flutter/material.dart';

import '../models/lugar_turistico.dart';

class LugarImagen extends StatelessWidget {
  const LugarImagen({
    required this.lugar,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final LugarTuristico lugar;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final etiqueta = 'Imagen de ${lugar.nombre}';
    final url = lugar.imagenUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: etiqueta,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return _marcador(context);
        },
        errorBuilder: (context, error, stackTrace) => _marcador(context),
      );
    }

    final asset = lugar.imagenAsset;
    if (asset != null && asset.isNotEmpty) {
      return Image.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: etiqueta,
        errorBuilder: (context, error, stackTrace) => _marcador(context),
      );
    }

    return _marcador(context);
  }

  Widget _marcador(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}
