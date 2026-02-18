import 'package:flutter/material.dart';
import 'package:recetario_app/appFolder/lista_recetas.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
   const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: true,
      home: ListaRecetas()

    );
  }
}       