import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../views/autenticacion_page.dart';

bool get haySesionIniciada =>
    Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;

Future<bool> exigirSesion(BuildContext context) async {
  if (haySesionIniciada) return true;

  final continuar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Inicia sesión para continuar'),
      content: const Text(
        'Necesitas una cuenta para guardar favoritos y planear visitas.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Iniciar sesión'),
        ),
      ],
    ),
  );
  if (continuar != true || !context.mounted) return false;

  await Navigator.push<void>(
    context,
    MaterialPageRoute(builder: (_) => const AutenticacionPage()),
  );
  return context.mounted && haySesionIniciada;
}
