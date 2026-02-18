import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recetario_app/database/database_helper.dart';
import 'lista_recetas.dart';
import 'receta_nueva.dart';
import 'dart:io';

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
  File? _imagenSeleccionada;
  TipoReceta? tipoReceta;
  Dificultad? tipoDificultad;
  List<String> ingredientes = [""];
  List<String> instrucciones=[""];

  final ImagePicker _picker = ImagePicker();

  
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
                decoration: const InputDecoration(labelText: "tiempo"),
              ),
              TextField(
                controller: _starsController,
                decoration: const InputDecoration(labelText: "puntuaje"),
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
                    ...ingredientes.asMap().entries.map((entry) {
                      int index = entry.key;
                      String valor = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (texto) {
                                ingredientes[index] = texto;
                              },
                              decoration: InputDecoration(
                                labelText: "Ingrediente ${index + 1}",
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
                      label: const Text("Agregar Ingrediente"),
                      onPressed: () {
                        setState(() {
                          ingredientes.add("");
                        });
                      },
                    ),
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
                                ingredientes[index] = texto;
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
         
                    // 2️⃣ Crear la receta
                    final nuevaReceta = RecetaModel(
                      titulo: _tituloController.text,
                      description: _descripcionController.text,
                      urlImage: _imagenSeleccionada != null
                          ? _imagenSeleccionada!.path
                          : "assets/images/panCake.jpg", // placeholder
                      stars: 5,
                      tiempo: 30,
                      valoresNutricional: ValoresNutricionales(
                        carbohidratos: 20,
                        grasas: 5,
                        azucares: 5,
                        proteinas: 5,
                      ),
                      instrucciones: instrucciones,
                      ingredientes: ingredientes,
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
