import 'dart:async';

import 'package:flutter/material.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TurisAGS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008577)),
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}
