import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recetario_app/database/database_helper.dart';
import 'lista_recetas.dart';
import 'receta_nueva.dart';
import 'dart:io';


class IngredienteItem {
  String nombre;
  double cantidad;
  MedidaPeso medida;

  IngredienteItem({
    this.nombre = "",
    this.cantidad = 0.0,
    this.medida = MedidaPeso.gr,
  });
}

class RecetaNueva extends StatefulWidget {
  final VoidCallback onRecetaAgregada;

  const RecetaNueva({super.key, required this.onRecetaAgregada});

  @override
  State<RecetaNueva> createState() => _RecetaNuevaState();
}

class _RecetaNuevaState extends State<RecetaNueva> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _tiempoController = TextEditingController();
  final _starsController = TextEditingController();

  //Valores Nutri
  List<IngredienteItem> ingredientesNutri = [IngredienteItem(),];
  ValoresNutricionales? valoresNutricionalesPasar;
  File? _imagenSeleccionada;
  TipoReceta? tipoReceta;
  Dificultad? tipoDificultad;
  List<String> ingredientes = [""];
  List<String> instrucciones=[""];

  final ImagePicker _picker = ImagePicker();

  //Nutricion

  String normalizarIngrediente(String nombre) {
  nombre = nombre.toLowerCase().trim();

  // reglas simples de plural
  if (nombre.endsWith('s')) {
    nombre = nombre.substring(0, nombre.length - 1);
  }

  // reemplazos comunes
  if (nombre == 'huevos') return 'huevo';
  if (nombre == 'tomates') return 'tomate';
  // ...más reglas según necesidad

  return nombre;
}


  double convertirAGramos(IngredienteItem item) {
  switch (item.medida) {
    case MedidaPeso.gr:
      return item.cantidad;

    case MedidaPeso.kg:
      return item.cantidad * 1000;

    case MedidaPeso.mgr:
      return item.cantidad / 1000;
    
    case MedidaPeso.cuch:
      return item.cantidad * 12;

    case MedidaPeso.un:
      return item.cantidad * 50;

    default:
      return item.cantidad; // fallback
  }
}


  Future<ValoresNutricionales> calcularNutricionTotal(
    List<IngredienteItem> ingredientes,BuildContext context) async {

  double totalCarbs = 0;
  double totalGrasas = 0;
  double totalAzucares = 0;
  double totalProteinas = 0;
  double totalPeso=0;

  for (var ingrediente in ingredientes) {

    if (ingrediente.nombre.isEmpty || ingrediente.cantidad <= 0) continue;

    //Normalizamos, en caso de que el usuario ponga huevos en vez de huevo.
    String ingredienteNombre = normalizarIngrediente(ingrediente.nombre);

    final data = await DatabaseHelper.instance
        .buscarIngrediente(ingredienteNombre);

    if (data != null) {

      double gramos = convertirAGramos(ingrediente);
      totalPeso+=gramos;

      double factor = gramos / 100;

      totalCarbs += (data['carbohidratos'] ?? 0) * factor;
      totalGrasas += (data['grasas'] ?? 0) * factor;
      totalAzucares += (data['azucares'] ?? 0) * factor;
      totalProteinas += (data['proteinas'] ?? 0) * factor;

     

    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ingrediente '${ingrediente.nombre}' no soportado"))
      );
    }
  }

  if (totalPeso == 0) totalPeso = 1; // evitar división por 0
  double factor2 = 100 / totalPeso;

  return ValoresNutricionales(
    carbohidratos: double.parse((totalCarbs * factor2).toStringAsFixed(1)),
    grasas: double.parse((totalGrasas * factor2).toStringAsFixed(1)),
    azucares: double.parse((totalAzucares * factor2).toStringAsFixed(1)),
    proteinas: double.parse((totalProteinas * factor2).toStringAsFixed(1)),
  );
}

  
  //Seleccionar Imagen

  Future<void> seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }

  double porcentaje = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Receta")),
      body: 
       SingleChildScrollView(
         child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              GestureDetector(
                            onTap: seleccionarImagen,
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[200],
                              ),
                              child: _imagenSeleccionada != null
                                  ? Image.file(_imagenSeleccionada!, fit: BoxFit.cover)
                                  : const Center(child: Text("Selecciona una imagen")),
                            ),
              ),
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
              TextField(
                controller: _tiempoController,
                decoration: const InputDecoration(labelText: "tiempo en minutos"),
              ),
              TextField(
                controller: _starsController,
                decoration: const InputDecoration(labelText: "puntuaje ""4"""),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: DropdownButton<TipoReceta>(
                  value: tipoReceta,
                  hint: const Text("Selecciona tipo de receta"),
                  items: TipoReceta.values.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      tipoReceta = valor;
                    });
                  },
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: DropdownButton<Dificultad>(
                  value: tipoDificultad,
                  hint: const Text("Selecciona tipo de dificultad"),
                  items: Dificultad.values.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      tipoDificultad = valor;
                    });
                  },
                ),
              ),
              //Ingredientes
              Container(
                alignment: Alignment.topLeft,
                child: Text("Ingredientes:",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,decoration: TextDecoration.underline),textAlign: TextAlign.left)),
              
              Column(
                children: [
                  ...ingredientesNutri.asMap().entries.map((entry) {
                    int index = entry.key;
                    IngredienteItem item = entry.value;

                    return Row(
                      children: [
                        /// Nombre ingrediente
                        Expanded(
                          child: TextField(
                            onChanged: (texto) {
                              item.nombre = texto;
                            },
                            decoration: InputDecoration(
                              labelText: "Ingrediente ${index + 1}",
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// Cantidad
                        SizedBox(
                          width: 70,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (texto) {
                              item.cantidad = double.tryParse(texto) ?? 0;
                            },
                            decoration: const InputDecoration(
                              labelText: "Cant",
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// Medida
                        DropdownButton<MedidaPeso>(
                          value: item.medida,
                          items: MedidaPeso.values.map((tipo) {
                            return DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo.name),
                            );
                          }).toList(),
                          onChanged: (valor) {
                            setState(() {
                              item.medida = valor!;
                            });
                          },
                        ),
                        

                        /// Eliminar ingrediente
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              ingredientesNutri.removeAt(index);
                            });
                          },
                        ),
                      ],
                    );
                  }).toList(),
                        TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Agregar Ingrediente"),
                      onPressed: () {
                        setState(() {
                          ingredientesNutri.add(IngredienteItem());
                        });
                      },
                    )
                ],
              ),

              //Instrucciones
              Container(
                alignment: Alignment.topLeft,
                child: Text("Instrucciones:",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,decoration: TextDecoration.underline),textAlign: TextAlign.left)),
              
              Column(
                  children: [
                    ...instrucciones.asMap().entries.map((entry) {
                      int index = entry.key;
                      String valor = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (texto) {
                                instrucciones[index] = texto;
                              },
                              decoration: InputDecoration(
                                labelText: "Instrucciones ${index + 1}",
                              ),
                              controller: TextEditingController(text: valor),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                ingredientes.removeAt(index);
                              });
                            },
                          )
                        ],
                      );
                    }).toList(),
         
                    // Botón para agregar ingrediente
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Agregar Instruccion"),
                      onPressed: () {
                        setState(() {
                          instrucciones.add("");
                        });
                      },
                    ),
                  ],
                
              ),
            
            
            
            const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // 1️⃣ Validar campos obligatorios
                    if (_tituloController.text.isEmpty ||
                        _descripcionController.text.isEmpty ||
                        tipoReceta == null ||
                        tipoDificultad == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Completa todos los campos y selecciona tipo y dificultad"),
                        ),
                      );
                      return; // Salimos sin guardar
                    }
                    final valoresCalculados = await calcularNutricionTotal(ingredientesNutri,context);
         
                    // 2️⃣ Crear la receta
                    final nuevaReceta = RecetaModel(
                      titulo: _tituloController.text,
                      description: _descripcionController.text,
                      urlImage: _imagenSeleccionada != null
                          ? _imagenSeleccionada!.path
                          : "assets/images/panCake.jpg", // placeholder
                      stars: 5,
                      tiempo: 30,
                      valoresNutricional: valoresCalculados,
                      instrucciones: instrucciones,
                      ingredientes: ingredientesNutri.map((e) => e.nombre).where((e) => e.isNotEmpty).toList(),
                      dificultad: tipoDificultad!, // seguro porque ya validamos
                      tipoReceta: tipoReceta!,     // seguro porque ya validamos
                    );
         
                    // 3️⃣ Insertar en la base de datos
                    await DatabaseHelper.instance.insertReceta(nuevaReceta.toMap());
         
                    // 4️⃣ Llamar callback para recargar lista
                    widget.onRecetaAgregada();
         
                    // 5️⃣ Volver a la pantalla anterior
                    Navigator.pop(context);
                  },
                  child: const Text("Guardar Receta"),
                )           
            ],
          ),
               ),
       ),
    );
  }
}
