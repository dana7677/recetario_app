import 'dart:io';

import 'package:flutter/material.dart';
import 'package:recetario_app/appFolder/receta_details.dart';
import 'package:recetario_app/appFolder/receta_nueva.dart';
import 'package:recetario_app/database/database_helper.dart';

/// ENUMS BIEN TIPADOS
enum MedidaPeso { mgr, gr, kg, un , cuch }
enum Dificultad { dificil, avanzado, medio, facil }
enum TipoReceta { desayuno, almuerzo, comida, bebida, postres, todas }

class ValoresNutricionales {
  final double carbohidratos;
  final double grasas;
  final double azucares;
  final double proteinas;

  ValoresNutricionales({
    required this.carbohidratos,
    required this.grasas,
    required this.azucares,
    required this.proteinas,
  });
}

/// MODELO
class RecetaModel {
  final int? id;
  final String titulo;
  final String description;
  final String urlImage;
  final double stars;
  final int tiempo;
  final ValoresNutricionales valoresNutricional;
  final List<String> instrucciones;
  final List<String> ingredientes;
  final Dificultad dificultad;
  final TipoReceta tipoReceta;

  RecetaModel({
    this.id,
    required this.titulo,
    required this.description,
    required this.urlImage,
    required this.stars,
    required this.tiempo,
    required this.valoresNutricional,
    required this.instrucciones,
    required this.ingredientes,
    required this.dificultad,
    required this.tipoReceta,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'description': description,
      'urlImage': urlImage,
      'stars': stars,
      'tiempo': tiempo,
      'carbohidratos': valoresNutricional.carbohidratos,
      'grasas': valoresNutricional.grasas,
      'azucares': valoresNutricional.azucares,
      'proteinas': valoresNutricional.proteinas,
      'instrucciones': instrucciones.join('|'),
      'ingredientes': ingredientes.join('|'),
      'dificultad': dificultad.index,
      'tipoReceta': tipoReceta.index,
    };
  }

  factory RecetaModel.fromMap(Map<String, dynamic> map) {
    return RecetaModel(
      id: map['id'],
      titulo: map['titulo'],
      description: map['description'],
      urlImage: map['urlImage'],
      stars: map['stars'],
      tiempo: map['tiempo'],
      valoresNutricional: ValoresNutricionales(
        carbohidratos: map['carbohidratos'],
        grasas: map['grasas'],
        azucares: map['azucares'],
        proteinas: map['proteinas'],
      ),
      instrucciones: map['instrucciones'].split('|'),
      ingredientes: map['ingredientes'].split('|'),
      dificultad: Dificultad.values[map['dificultad']],
      tipoReceta: TipoReceta.values[map['tipoReceta']],
    );
  }
}

String getDificultad(Dificultad dificultad) {
  switch (dificultad) {
    case Dificultad.dificil:
      return "Dificil";
    case Dificultad.avanzado:
      return "Avanzado";
    case Dificultad.medio:
      return "Medio";
    case Dificultad.facil:
      return "Facil";
    default:
      return "None";
  }
}

/// ITEM DE RECETA
class RecetaItem extends StatelessWidget {
  final RecetaModel receta;
  final VoidCallback onEliminar;
  final VoidCallback showDetails;

  const RecetaItem({
    super.key,
    required this.receta,
    required this.onEliminar,
    required this.showDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showDetails,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(10),
        elevation: 5,
        color: const Color.fromARGB(255,255,255,252),
        
        shadowColor: 
          const Color.fromARGB(180, 0, 0, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color.fromARGB(78, 0, 0, 0)
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    child: receta.urlImage.startsWith('/')
                        ? Image.file(
                            File(receta.urlImage),
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            receta.urlImage,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 5,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(
                        Icons.dehaze,
                        color: Colors.white,
                        size: 30,
                        weight: 1,
                      ),
                      onPressed: showDetails,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receta.titulo,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    receta.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 60,
                        width: 80,
                        child: Card(
                            margin: const EdgeInsets.all(12),
                            elevation: 5,
                            color: const Color.fromARGB(121, 0, 255, 17),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "⭐ ${receta.stars}",
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 60,
                        width: 120,
                        child: Card(
                            margin: const EdgeInsets.all(12),
                            elevation: 5,
                            color: const Color.fromARGB(121, 201, 9, 253),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "⏱ ${receta.tiempo} min",
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 60,
                        width: 120,
                        child: Card(
                            margin: const EdgeInsets.all(12),
                            elevation: 5,
                            color: const Color.fromARGB(121, 255, 153, 0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "📊 ${getDificultad(receta.dificultad)}",
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// LISTA PRINCIPAL
class ListaRecetas extends StatefulWidget {
  const ListaRecetas({super.key});

  @override
  State<ListaRecetas> createState() => _ListaRecetasState();
}

class _ListaRecetasState extends State<ListaRecetas> {
  TipoReceta filtroActivo = TipoReceta.todas;
  List<RecetaModel> listaRecetas = [];
  List<RecetaModel> listaRecetaOriginal = [];

  bool isIconFilter(TipoReceta iconFilter) {
    return filtroActivo == iconFilter;
  }

  @override
  void initState() {
    super.initState();
    poblarBaseDeDatos().then((_) => cargarRecetasDesdeDB());
  }

  // BORRA TODO Y POBLA LA DB CON RECETAS
  Future<void> poblarBaseDeDatos() async {
    final dbHelper = DatabaseHelper.instance;

    // 1️⃣ Borrar todas las recetas
    //await dbHelper.deleteAllRecetas();

      final recetasExistentes = await dbHelper.getRecetas();
      if (recetasExistentes.isNotEmpty) return;

    // 2️⃣ Lista de recetas iniciales
    List<RecetaModel> recetasIniciales = [
            RecetaModel(
          titulo: "Carrilleras con puré de patatas",
          description: "Carrilleras cocinadas a fuego lento hasta quedar melosas.",
          urlImage: "assets/images/carrillerasConPureDePatatas.jpg",
          stars: 5,
          tiempo: 120,
          valoresNutricional: ValoresNutricionales(
            carbohidratos: 10,
            grasas: 18,
            azucares: 2,
            proteinas: 15,
          ),
          ingredientes: [
            "Carrilleras de cerdo",
            "Patatas",
            "Vino tinto",
            "Cebolla",
            "Zanahoria",
            "Caldo de carne",
            "Aceite de oliva",
            "Sal y pimienta",
          ],
          instrucciones: [
            "Sellar las carrilleras.",
            "Sofreír verduras.",
            "Añadir vino y reducir.",
            "Cocinar 2 horas a fuego lento.",
            "Preparar puré y servir.",
          ],
          dificultad: Dificultad.dificil,
          tipoReceta: TipoReceta.comida,
        ),

        RecetaModel(
          titulo: "Ensalada Mediterránea",
          description: "Ensalada fresca con tomate, pepino, aceitunas y queso feta.",
          urlImage: "assets/images/ensaladaMediterranea.jpg",
          stars: 4,
          tiempo: 15,
          valoresNutricional: ValoresNutricionales(
            carbohidratos: 6,
            grasas: 9,
            azucares: 3,
            proteinas: 3,
          ),
          ingredientes: [
            "Tomate",
            "Pepino",
            "Aceitunas",
            "Queso feta",
            "Aceite de oliva",
            "Orégano",
          ],
          instrucciones: [
            "Cortar verduras.",
            "Mezclar en bol.",
            "Añadir queso.",
            "Aliñar y servir.",
          ],
          dificultad: Dificultad.facil,
          tipoReceta: TipoReceta.almuerzo,
        ),

        RecetaModel(
          titulo: "Burguer clásica",
          description: "Hamburguesa de carne jugosa con queso, lechuga, tomate y salsa especial en pan tostado.",
          urlImage: "assets/images/burguerClasica.jpg",
          stars: 4,
          tiempo: 25,
          valoresNutricional: ValoresNutricionales(
            carbohidratos: 20,
            grasas: 17,
            azucares: 4,
            proteinas: 13,
          ),
          ingredientes: [
            "Carne picada",
            "Pan de hamburguesa",
            "Queso",
            "Lechuga",
            "Tomate",
            "Salsa especial",
          ],
          instrucciones: [
            "Formar hamburguesa.",
            "Cocinar a la plancha.",
            "Tostar pan.",
            "Montar y servir.",
          ],
          dificultad: Dificultad.medio,
          tipoReceta: TipoReceta.comida,
        ),

        RecetaModel(
          titulo: "Lasaña de carne",
          description: "Capas de pasta rellenas de carne boloñesa y bechamel, gratinadas al horno con queso.",
          urlImage: "assets/images/lasanaDeCarne.jpg",
          stars: 5,
          tiempo: 90,
          valoresNutricional: ValoresNutricionales(
            carbohidratos: 18,
            grasas: 12,
            azucares: 3,
            proteinas: 11,
          ),
          ingredientes: [
            "Placas de lasaña",
            "Carne picada",
            "Tomate triturado",
            "Bechamel",
            "Queso rallado",
          ],
          instrucciones: [
            "Cocinar la carne con tomate.",
            "Preparar la bechamel.",
            "Montar capas.",
            "Hornear 40 minutos.",
          ],
          dificultad: Dificultad.avanzado,
          tipoReceta: TipoReceta.comida,
        ),

        RecetaModel(
          titulo: "Noodles de arroz y pollo",
          description: "Fideos de arroz salteados con pollo y verduras en salsa de soja ligeramente especiada.",
          urlImage: "assets/images/noodlesArrozYPollo.jpg",
          stars: 4,
          tiempo: 30,
          valoresNutricional: ValoresNutricionales(
            carbohidratos: 22,
            grasas: 6,
            azucares: 2,
            proteinas: 9,
          ),
          ingredientes: [
            "Fideos de arroz",
            "Pechuga de pollo",
            "Verduras variadas",
            "Salsa de soja",
          ],
          instrucciones: [
            "Cocer noodles.",
            "Saltear pollo.",
            "Añadir verduras.",
            "Mezclar todo y servir.",
          ],
          dificultad: Dificultad.medio,
          tipoReceta: TipoReceta.almuerzo,
        ),

        RecetaModel(
          titulo: "Pan casero",
          description: "Pan artesanal de corteza crujiente y miga esponjosa, perfecto para acompañar cualquier comida.",
          urlImage: "assets/images/pan.jpg",
          stars: 4,
          tiempo: 180,
          valoresNutricional: ValoresNutricionales(
            carbohidratos: 49,
            grasas: 3,
            azucares: 5,
            proteinas: 9,
          ),
          ingredientes: [
            "Harina",
            "Agua",
            "Levadura",
            "Sal",
          ],
          instrucciones: [
            "Mezclar ingredientes.",
            "Amasar.",
            "Dejar fermentar.",
            "Hornear 40 minutos.",
          ],
          dificultad: Dificultad.medio,
          tipoReceta: TipoReceta.almuerzo,
        ),

        RecetaModel(
          titulo: "Pancake",
          description: "Tortitas esponjosas ideales para el desayuno, acompañadas de sirope o fruta fresca.",
          urlImage: "assets/images/panCake.jpg",
          stars: 4,
          tiempo: 20,
          valoresNutricional: ValoresNutricionales(
            carbohidratos: 28,
            grasas: 9,
            azucares: 8,
            proteinas: 6,
          ),
          ingredientes: [
            "Harina",
            "Huevo",
            "Leche",
            "Azúcar",
          ],
          instrucciones: [
            "Mezclar ingredientes.",
            "Verter en sartén.",
            "Cocinar ambos lados.",
          ],
          dificultad: Dificultad.facil,
          tipoReceta: TipoReceta.desayuno,
        ),

        RecetaModel(
          titulo: "Pimientos asados",
          description: "Pimientos rojos asados lentamente, aliñados con aceite de oliva y ajo.",
          urlImage: "assets/images/pimientosAsados.jpg",
          stars: 4,
          tiempo: 45,
          valoresNutricional: ValoresNutricionales(
            carbohidratos: 6,
            grasas: 4,
            azucares: 5,
            proteinas: 1,
          ),
          ingredientes: [
            "Pimientos rojos",
            "Aceite de oliva",
            "Ajo",
            "Sal",
          ],
          instrucciones: [
            "Asar 40 minutos.",
            "Pelar.",
            "Aliñar y servir.",
          ],
          dificultad: Dificultad.facil,
          tipoReceta: TipoReceta.almuerzo,
        ),

        RecetaModel(
          titulo: "Smoothies de Frutas",
          description: "Bebida refrescante a base de frutas naturales trituradas, ideal para un desayuno saludable.",
          urlImage: "assets/images/smoothieDeFrutas.jpg",
          stars: 4,
          tiempo: 10,
          valoresNutricional: ValoresNutricionales(
            carbohidratos: 14,
            grasas: 1,
            azucares: 12,
            proteinas: 1,
          ),
          ingredientes: [
            "Frutas variadas",
            "Yogur o leche",
          ],
          instrucciones: [
            "Triturar todo.",
            "Servir frío.",
          ],
          dificultad: Dificultad.facil,
          tipoReceta: TipoReceta.postres,
        ),

        RecetaModel(
          titulo: "Tacos al pastor",
          description: "Tacos de cerdo marinados con especias y piña, servidos en tortilla de maíz.",
          urlImage: "assets/images/tacoAlPastor.jpg",
          stars: 5,
          tiempo: 60,
          valoresNutricional: ValoresNutricionales(
            carbohidratos: 19,
            grasas: 11,
            azucares: 3,
            proteinas: 14,
          ),
          ingredientes: [
            "Carne de cerdo",
            "Tortillas de maíz",
            "Piña",
            "Cebolla",
            "Especias",
          ],
          instrucciones: [
            "Marinar carne.",
            "Cocinar.",
            "Montar tacos.",
          ],
          dificultad: Dificultad.medio,
          tipoReceta: TipoReceta.comida,
        ),

        RecetaModel(
          titulo: "Tostada con arándanos",
          description: "Tostada crujiente con yogur o queso crema y arándanos frescos por encima.",
          urlImage: "assets/images/tostadasConArandanosYKiwi.jpg",
          stars: 4,
          tiempo: 10,
          valoresNutricional: ValoresNutricionales(
            carbohidratos: 35,
            grasas: 5,
            azucares: 9,
            proteinas: 7,
          ),
          ingredientes: [
            "Pan integral",
            "Yogur o queso crema",
            "Arándanos",
            "Miel",
          ],
          instrucciones: [
            "Tostar pan.",
            "Untar yogur.",
            "Añadir fruta.",
          ],
          dificultad: Dificultad.facil,
          tipoReceta: TipoReceta.desayuno,
        ),

      // ... aquí puedes añadir todas tus demás recetas manualmente siguiendo el mismo formato
    ];

    // 3️⃣ Insertar en la DB
    for (var receta in recetasIniciales) {
      await dbHelper.insertReceta(receta.toMap());
    }

    print("Base de datos poblada con recetas iniciales");
  }

  Future<void> cargarRecetasDesdeDB() async {
    final dbHelper = DatabaseHelper.instance;
    final rows = await dbHelper.getRecetas();

    List<RecetaModel> recetasDB = rows.map((row) {
      return RecetaModel(
        id: row['id'],
        titulo: row['titulo'],
        description: row['description'],
        urlImage: row['urlImage'],
        stars: row['stars'],
        tiempo: row['tiempo'],
        valoresNutricional: ValoresNutricionales(
          carbohidratos: row['carbohidratos'],
          grasas: row['grasas'],
          azucares: row['azucares'],
          proteinas: row['proteinas'],
        ),
        instrucciones: (row['instrucciones'] as String).split('|'),
        ingredientes: (row['ingredientes'] as String).split('|'),
        dificultad: Dificultad.values[row['dificultad']],
        tipoReceta: TipoReceta.values[row['tipoReceta']],
      );
    }).toList();

    setState(() {
      listaRecetaOriginal = recetasDB;
      listaRecetas = recetasDB;
    });

    print("Recetas cargadas desde la base de datos: ${listaRecetas.length}");
  }

  void eliminarReceta(int index) {
    setState(() {
      listaRecetas.removeAt(index);
    });
  }

  void showDetails(RecetaModel receta) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecetaDetails(receta: receta)),
    );
  }

  void filterRecipesBy(TipoReceta tipoFiltrar) {
    setState(() {
      if (tipoFiltrar != filtroActivo || tipoFiltrar != TipoReceta.todas) {
        listaRecetas =
            listaRecetaOriginal.where((r) => r.tipoReceta == tipoFiltrar).toList();
        filtroActivo = tipoFiltrar;
      } else {
        listaRecetas = listaRecetaOriginal;
        filtroActivo = TipoReceta.todas;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista Recetas"),
        centerTitle: true,
        backgroundColor:  const Color.fromARGB(255,244,241,222),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {
                    filterRecipesBy(TipoReceta.desayuno);
                  },
                  icon: Icon(
                    Icons.free_breakfast_outlined,
                    color: isIconFilter(TipoReceta.desayuno)
                        ? Colors.amber
                        : Colors.grey,
                  )),
              IconButton(
                  onPressed: () {
                    filterRecipesBy(TipoReceta.almuerzo);
                  },
                  icon: Icon(
                    Icons.lunch_dining_outlined,
                    color: isIconFilter(TipoReceta.almuerzo)
                        ? Colors.amber
                        : Colors.grey,
                  )),
              IconButton(
                  onPressed: () {
                    filterRecipesBy(TipoReceta.comida);
                  },
                  icon: Icon(
                    Icons.fastfood,
                    color: isIconFilter(TipoReceta.comida)
                        ? Colors.amber
                        : Colors.grey,
                  )),
              IconButton(
                  onPressed: () {
                    filterRecipesBy(TipoReceta.postres);
                  },
                  icon: Icon(
                    Icons.icecream_outlined,
                    color:
                        isIconFilter(TipoReceta.postres) ? Colors.amber : Colors.grey,
                  )),
              IconButton(
                  onPressed: () {
                    filterRecipesBy(TipoReceta.bebida);
                  },
                  icon: Icon(
                    Icons.wine_bar,
                    color:
                        isIconFilter(TipoReceta.bebida) ? Colors.amber : Colors.grey,
                  )),
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255,244,241,222),
      body: listaRecetas.isEmpty
          ? const Center(
              child: Text(
                "No hay recetas todavía 🍳",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: listaRecetas.length,
              itemBuilder: (context, index) {
                final receta = listaRecetas[index];
                return RecetaItem(
                  receta: receta,
                  onEliminar: () => eliminarReceta(index),
                  showDetails: () => showDetails(receta),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecetaNueva(
              onRecetaAgregada: cargarRecetasDesdeDB,
            )),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
