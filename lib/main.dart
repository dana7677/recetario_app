import 'package:flutter/material.dart';
import 'package:recetario_app/appFolder/lista_recetas.dart';
import 'package:recetario_app/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';


void main() async {
WidgetsFlutterBinding.ensureInitialized(); // necesario para async en main

  final dbHelper = DatabaseHelper.instance;

  // Abrimos la DB
  final db = await dbHelper.database;

  // Verificamos si ya hay datos en nutricion
  final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM nutricion')) ?? 0;
  if (count == 0) {
    await dbHelper.poblarNutricion(); // se insertan todos los ingredientes
  }

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
      home: const ListaRecetas(),
    );
  }
}

