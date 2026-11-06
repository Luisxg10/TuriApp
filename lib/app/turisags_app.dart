import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'dependencias.dart';
import '../repositories/clima_repository.dart';
import '../views/lugares_page.dart';

final climaRepository = ClimaRepository();

class TurisAGSApp extends StatefulWidget {
  const TurisAGSApp({super.key});

  @override
  State<TurisAGSApp> createState() => _TurisAGSAppState();
}

class _TurisAGSAppState extends State<TurisAGSApp> {
  StreamSubscription<User?>? _suscripcionDeSesion;

  @override
  void initState() {
    super.initState();
    if (Firebase.apps.isEmpty) {
      unawaited(favoritosViewModel.cargarFavoritos());
      unawaited(itinerarioViewModel.cargarVisitas());
    } else {
      _suscripcionDeSesion = FirebaseAuth.instance.authStateChanges().listen((
        _,
      ) {
        unawaited(favoritosViewModel.cargarFavoritos());
        unawaited(itinerarioViewModel.cargarVisitas());
      });
    }
  }

  @override
  void dispose() {
    unawaited(_suscripcionDeSesion?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TurisAGS',
      locale: const Locale('es', 'MX'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('es', 'MX')],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008577)),
        useMaterial3: true,
      ),
      home: const LugaresPage(),
    );
  }
}
