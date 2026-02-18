import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recetas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE recetas(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      titulo TEXT,
      description TEXT,
      urlImage TEXT,
      stars REAL,
      tiempo INTEGER,
      carbohidratos REAL,
      grasas REAL,
      azucares REAL,
      proteinas REAL,
      instrucciones TEXT,
      ingredientes TEXT,
      dificultad INTEGER,
      tipoReceta INTEGER
    )
    ''');
  }

  /// Inserta una receta (mapa de valores)
  Future<int> insertReceta(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('recetas', row);
  }

  /// Obtiene todas las recetas
  Future<List<Map<String, dynamic>>> getRecetas() async {
    final db = await instance.database;
    return await db.query('recetas', orderBy: 'id');
  }

  /// Cierra la base de datos
  Future close() async {
    final db = await instance.database;
    db.close();
  }
  Future<int> deleteAllRecetas() async {
  final db = await database;
  return await db.delete('recetas');
}
}
