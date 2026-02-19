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

    // 🔥 NUEVA TABLA NUTRICION
  await db.execute('''
    CREATE TABLE nutricion(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT UNIQUE,
      carbohidratos REAL,
      grasas REAL,
      azucares REAL,
      proteinas REAL
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


//Nutricion

  Future<Map<String, dynamic>?> buscarIngrediente(String nombre) async {
    final db = await instance.database;

    final resultado = await db.query(
      'nutricion',
      where: 'LOWER(nombre) LIKE ?',
      whereArgs: ['%${nombre.toLowerCase()}%'],
    );

    if (resultado.isNotEmpty) {
      return resultado.first;
    }

    return null;
  }

    Future<void> poblarNutricion() async {
    final db = await instance.database;

    final ingredientesBase = [
      {'nombre': 'arroz', 'carbohidratos': 28.0, 'grasas': 0.3, 'azucares': 0.1, 'proteinas': 2.7},
      {'nombre': 'pollo', 'carbohidratos': 0.0, 'grasas': 3.6, 'azucares': 0.0, 'proteinas': 31.0},
      {'nombre': 'huevo', 'carbohidratos': 1.1, 'grasas': 11.0, 'azucares': 1.1, 'proteinas': 13.0},
      {'nombre': 'patata', 'carbohidratos': 17.0, 'grasas': 0.1, 'azucares': 0.8, 'proteinas': 2.0},
      {'nombre': 'leche', 'carbohidratos': 5.0, 'grasas': 3.4, 'azucares': 5.0, 'proteinas': 3.4},
      {'nombre': 'tomate', 'carbohidratos': 3.9, 'grasas': 0.2, 'azucares': 2.6, 'proteinas': 0.9},
      {'nombre': 'cebolla', 'carbohidratos': 9.3, 'grasas': 0.1, 'azucares': 4.2, 'proteinas': 1.1},
      {'nombre': 'zanahoria', 'carbohidratos': 10.0, 'grasas': 0.2, 'azucares': 4.7, 'proteinas': 0.9},
      {'nombre': 'manzana', 'carbohidratos': 14.0, 'grasas': 0.2, 'azucares': 10.0, 'proteinas': 0.3},
      {'nombre': 'plátano', 'carbohidratos': 23.0, 'grasas': 0.3, 'azucares': 12.0, 'proteinas': 1.1},
      {'nombre': 'pan', 'carbohidratos': 49.0, 'grasas': 3.2, 'azucares': 5.0, 'proteinas': 9.0},
      {'nombre': 'queso', 'carbohidratos': 1.3, 'grasas': 33.0, 'azucares': 0.5, 'proteinas': 25.0},
      {'nombre': 'aceite', 'carbohidratos': 0.0, 'grasas': 100.0, 'azucares': 0.0, 'proteinas': 0.0},
      {'nombre': 'azúcar', 'carbohidratos': 100.0, 'grasas': 0.0, 'azucares': 100.0, 'proteinas': 0.0},
      {'nombre': 'sal', 'carbohidratos': 0.0, 'grasas': 0.0, 'azucares': 0.0, 'proteinas': 0.0},
      {'nombre': 'lentejas', 'carbohidratos': 20.0, 'grasas': 0.4, 'azucares': 1.8, 'proteinas': 9.0},
      {'nombre': 'nuez', 'carbohidratos': 14.0, 'grasas': 65.0, 'azucares': 2.6, 'proteinas': 15.0},
      {'nombre': 'salmón', 'carbohidratos': 0.0, 'grasas': 13.0, 'azucares': 0.0, 'proteinas': 20.0},
      {'nombre': 'brócoli', 'carbohidratos': 7.0, 'grasas': 0.4, 'azucares': 1.7, 'proteinas': 2.8},
      {'nombre': 'espinaca', 'carbohidratos': 3.6, 'grasas': 0.4, 'azucares': 0.4, 'proteinas': 2.9},
      {'nombre': 'pasta', 'carbohidratos': 75.0, 'grasas': 1.5, 'azucares': 2.0, 'proteinas': 13.0},
      {'nombre': 'tomate frito', 'carbohidratos': 7.0, 'grasas': 3.0, 'azucares': 5.0, 'proteinas': 1.0},
      {'nombre': 'pechuga de pavo', 'carbohidratos': 0.0, 'grasas': 1.5, 'azucares': 0.0, 'proteinas': 29.0},
      {'nombre': 'merluza', 'carbohidratos': 0.0, 'grasas': 2.0, 'azucares': 0.0, 'proteinas': 18.0},
      {'nombre': 'yogur natural', 'carbohidratos': 4.7, 'grasas': 3.3, 'azucares': 4.7, 'proteinas': 3.5},
      {'nombre': 'mantequilla', 'carbohidratos': 0.1, 'grasas': 81.0, 'azucares': 0.1, 'proteinas': 1.0},
      {'nombre': 'harina de trigo', 'carbohidratos': 76.0, 'grasas': 1.0, 'azucares': 0.3, 'proteinas': 10.0},
      {'nombre': 'maíz', 'carbohidratos': 19.0, 'grasas': 1.2, 'azucares': 0.6, 'proteinas': 3.3},
      {'nombre': 'avena', 'carbohidratos': 66.0, 'grasas': 7.0, 'azucares': 0.9, 'proteinas': 17.0},
      {'nombre': 'cacahuete', 'carbohidratos': 16.0, 'grasas': 49.0, 'azucares': 4.7, 'proteinas': 26.0},
      {'nombre': 'almendra', 'carbohidratos': 22.0, 'grasas': 49.0, 'azucares': 4.4, 'proteinas': 21.0},
      {'nombre': 'garbanzos', 'carbohidratos': 27.0, 'grasas': 2.6, 'azucares': 4.8, 'proteinas': 9.0},
      {'nombre': 'champiñón', 'carbohidratos': 3.3, 'grasas': 0.3, 'azucares': 1.0, 'proteinas': 3.1},
      {'nombre': 'pimiento', 'carbohidratos': 6.0, 'grasas': 0.2, 'azucares': 4.2, 'proteinas': 0.9},
      {'nombre': 'berenjena', 'carbohidratos': 6.0, 'grasas': 0.2, 'azucares': 3.2, 'proteinas': 1.0},
      {'nombre': 'calabacín', 'carbohidratos': 3.1, 'grasas': 0.3, 'azucares': 2.5, 'proteinas': 1.2},
      {'nombre': 'sopa de verduras', 'carbohidratos': 5.0, 'grasas': 1.0, 'azucares': 2.0, 'proteinas': 1.0},
      {'nombre': 'atún en agua', 'carbohidratos': 0.0, 'grasas': 0.8, 'azucares': 0.0, 'proteinas': 23.0},
      {'nombre': 'bacalao', 'carbohidratos': 0.0, 'grasas': 0.9, 'azucares': 0.0, 'proteinas': 18.0},
      {'nombre': 'tofu', 'carbohidratos': 1.9, 'grasas': 4.8, 'azucares': 0.3, 'proteinas': 8.0},
      {'nombre': 'calabaza', 'carbohidratos': 7.0, 'grasas': 0.1, 'azucares': 3.0, 'proteinas': 1.0},
      {'nombre': 'espárragos', 'carbohidratos': 3.9, 'grasas': 0.1, 'azucares': 1.2, 'proteinas': 2.2},
      {'nombre': 'repollo', 'carbohidratos': 5.8, 'grasas': 0.1, 'azucares': 3.2, 'proteinas': 1.3},
      {'nombre': 'coliflor', 'carbohidratos': 5.0, 'grasas': 0.3, 'azucares': 2.0, 'proteinas': 1.9},
      {'nombre': 'pepino', 'carbohidratos': 3.6, 'grasas': 0.1, 'azucares': 1.7, 'proteinas': 0.7},
      {'nombre': 'remolacha', 'carbohidratos': 10.0, 'grasas': 0.2, 'azucares': 6.8, 'proteinas': 1.6},
      {'nombre': 'mango', 'carbohidratos': 15.0, 'grasas': 0.2, 'azucares': 14.0, 'proteinas': 0.8},
      {'nombre': 'piña', 'carbohidratos': 13.0, 'grasas': 0.1, 'azucares': 10.0, 'proteinas': 0.5},
      {'nombre': 'pera', 'carbohidratos': 15.0, 'grasas': 0.1, 'azucares': 10.0, 'proteinas': 0.4},
      {'nombre': 'arándanos', 'carbohidratos': 14.0, 'grasas': 0.3, 'azucares': 10.0, 'proteinas': 0.7},
      {'nombre': 'frambuesa', 'carbohidratos': 12.0, 'grasas': 0.7, 'azucares': 4.4, 'proteinas': 1.2},
      {'nombre': 'grosella', 'carbohidratos': 15.0, 'grasas': 0.4, 'azucares': 8.0, 'proteinas': 1.0},
      {'nombre': 'cebollino', 'carbohidratos': 4.4, 'grasas': 0.2, 'azucares': 2.3, 'proteinas': 3.3},
      {'nombre': 'perejil', 'carbohidratos': 6.3, 'grasas': 0.8, 'azucares': 0.9, 'proteinas': 3.0},
      {'nombre': 'albahaca', 'carbohidratos': 2.7, 'grasas': 0.6, 'azucares': 0.3, 'proteinas': 3.2},
      {'nombre': 'orégano', 'carbohidratos': 4.3, 'grasas': 7.0, 'azucares': 0.6, 'proteinas': 9.0},
      {'nombre': 'tomillo', 'carbohidratos': 24.0, 'grasas': 1.7, 'azucares': 2.6, 'proteinas': 9.1},
      {'nombre': 'jengibre', 'carbohidratos': 18.0, 'grasas': 0.8, 'azucares': 1.7, 'proteinas': 1.8},
      {'nombre': 'ajo', 'carbohidratos': 33.0, 'grasas': 0.5, 'azucares': 1.0, 'proteinas': 6.4},
      {'nombre': 'chile', 'carbohidratos': 9.5, 'grasas': 0.4, 'azucares': 5.3, 'proteinas': 2.0},
      {'nombre': 'aguacate', 'carbohidratos': 9.0, 'grasas': 15.0, 'azucares': 0.7, 'proteinas': 2.0},
      {'nombre': 'berenjena china', 'carbohidratos': 6.0, 'grasas': 0.2, 'azucares': 3.5, 'proteinas': 1.2},
      {'nombre': 'rúcula', 'carbohidratos': 3.7, 'grasas': 0.7, 'azucares': 2.1, 'proteinas': 2.6},
      {'nombre': 'col rizada', 'carbohidratos': 9.0, 'grasas': 0.6, 'azucares': 0.5, 'proteinas': 4.3},
      {'nombre': 'berenjena morada', 'carbohidratos': 6.0, 'grasas': 0.1, 'azucares': 3.2, 'proteinas': 1.0},
      {'nombre': 'repollo rojo', 'carbohidratos': 6.0, 'grasas': 0.2, 'azucares': 3.0, 'proteinas': 1.2},
      {'nombre': 'col china', 'carbohidratos': 2.2, 'grasas': 0.1, 'azucares': 1.0, 'proteinas': 1.5},
      {'nombre': 'berenjena blanca', 'carbohidratos': 5.0, 'grasas': 0.1, 'azucares': 2.8, 'proteinas': 0.8},
      {'nombre': 'kiwi', 'carbohidratos': 15.0, 'grasas': 0.5, 'azucares': 9.0, 'proteinas': 1.1},
      {'nombre': 'fresa', 'carbohidratos': 8.0, 'grasas': 0.4, 'azucares': 4.9, 'proteinas': 0.7},
      {'nombre': 'arándano rojo', 'carbohidratos': 12.0, 'grasas': 0.3, 'azucares': 4.0, 'proteinas': 0.4},
      {'nombre': 'guisantes', 'carbohidratos': 14.0, 'grasas': 0.4, 'azucares': 5.0, 'proteinas': 5.4},
      {'nombre': 'remolacha cocida', 'carbohidratos': 10.0, 'grasas': 0.2, 'azucares': 7.0, 'proteinas': 1.6},
      {'nombre': 'cebolla roja', 'carbohidratos': 9.3, 'grasas': 0.1, 'azucares': 4.2, 'proteinas': 1.1},
      {'nombre': 'cebolla blanca', 'carbohidratos': 9.0, 'grasas': 0.1, 'azucares': 4.0, 'proteinas': 1.0},
      {'nombre': 'pasta integral', 'carbohidratos': 68.0, 'grasas': 2.0, 'azucares': 3.0, 'proteinas': 12.0},
      {'nombre': 'arroz integral', 'carbohidratos': 23.0, 'grasas': 1.0, 'azucares': 0.4, 'proteinas': 2.6},
      {'nombre': 'cebada', 'carbohidratos': 28.0, 'grasas': 1.2, 'azucares': 0.8, 'proteinas': 3.5},
      {'nombre': 'trigo sarraceno', 'carbohidratos': 71.0, 'grasas': 3.4, 'azucares': 0.9, 'proteinas': 13.0},
      {'nombre': 'soja', 'carbohidratos': 30.0, 'grasas': 20.0, 'azucares': 7.0, 'proteinas': 36.0},
      {'nombre': 'ternera', 'carbohidratos': 0.0, 'grasas': 10.0, 'azucares': 0.0, 'proteinas': 20.0},
      {'nombre': 'cordero', 'carbohidratos': 0.0, 'grasas': 16.0, 'azucares': 0.0, 'proteinas': 19.0},
      {'nombre': 'cerdo', 'carbohidratos': 0.0, 'grasas': 14.0, 'azucares': 0.0, 'proteinas': 21.0},
      {'nombre': 'aceitunas', 'carbohidratos': 6.0, 'grasas': 11.0, 'azucares': 0.5, 'proteinas': 1.0},
      {'nombre': 'bacon', 'carbohidratos': 1.0, 'grasas': 42.0, 'azucares': 0.5, 'proteinas': 37.0},
      {'nombre': 'jamón serrano', 'carbohidratos': 1.0, 'grasas': 12.0, 'azucares': 0.0, 'proteinas': 30.0},
      {'nombre': 'morcilla', 'carbohidratos': 18.0, 'grasas': 20.0, 'azucares': 2.0, 'proteinas': 13.0},
      {'nombre': 'chorizo', 'carbohidratos': 1.5, 'grasas': 35.0, 'azucares': 0.5, 'proteinas': 24.0},
    ];


    for (var ingrediente in ingredientesBase) {
        // Solo insertar si no existe
        final existente = await db.query(
          'nutricion',
          where: 'LOWER(nombre) = ?',
          whereArgs: [ingrediente['nombre'].toString().toLowerCase()],
        );

        if (existente.isEmpty) {
          await db.insert('nutricion', ingrediente,conflictAlgorithm: ConflictAlgorithm.ignore);
        }
    }
  }
}
