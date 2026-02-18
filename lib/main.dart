import 'package:flutter/material.dart';
import 'package:recetario_app/appFolder/lista_recetas.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // necesario si en initState haces async
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Recetario App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const ListaRecetas(), // tu lista se encargará de poblar y cargar DB
    );
  }
}
