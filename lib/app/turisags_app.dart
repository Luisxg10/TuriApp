import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'dependencias.dart';
import '../repositories/clima_repository.dart';
import '../views/inicio_page.dart';

final climaRepository = ClimaRepository();

class TurisAGSApp extends StatefulWidget {
  const TurisAGSApp({super.key});

  @override
  State<TurisAGSApp> createState() => _TurisAGSAppState();
}

class _TurisAGSAppState extends State<TurisAGSApp> {
  @override
  void initState() {
    super.initState();
    unawaited(favoritosViewModel.cargarFavoritos());
    unawaited(itinerarioViewModel.cargarVisitas());
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
      home: const InicioPage(),
    );
  }
}
