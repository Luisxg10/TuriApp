import 'package:flutter/material.dart';

import '../repositories/clima_repository.dart';
import '../views/inicio_page.dart';

final climaRepository = ClimaRepository();

class TurisAGSApp extends StatelessWidget {
  const TurisAGSApp({super.key});

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
