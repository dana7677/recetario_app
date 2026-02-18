import 'package:flutter/material.dart';
import 'package:recetario_app/database/database_helper.dart';
import 'lista_recetas.dart';
import 'receta_nueva.dart';

class RecetaNueva extends StatefulWidget {
  final VoidCallback onRecetaAgregada;

  const RecetaNueva({super.key, required this.onRecetaAgregada});

  @override
  State<RecetaNueva> createState() => _RecetaNuevaState();
}

class _RecetaNuevaState extends State<RecetaNueva> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  double porcentaje = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Receta")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Crear la receta
                final nuevaReceta = RecetaModel(
                  titulo: _tituloController.text,
                  description: _descripcionController.text,
                  urlImage: "assets/images/panCake.jpg", // placeholder
                  stars: 4,
                  tiempo: 30,
                  valoresNutricional: ValoresNutricionales(
                    carbohidratos: 20,
                    grasas: 5,
                    azucares: 5,
                    proteinas: 5,
                  ),
                  instrucciones: ["Paso 1", "Paso 2"],
                  ingredientes: ["Ingrediente 1", "Ingrediente 2"],
                  dificultad: Dificultad.facil,
                  tipoReceta: TipoReceta.desayuno,
                );

                // Insertar en la base de datos
                await DatabaseHelper.instance.insertReceta(nuevaReceta.toMap());

                // Llamar callback para recargar lista
                widget.onRecetaAgregada();

                // Volver a la pantalla anterior
                Navigator.pop(context);
              },
              child: const Text("Guardar Receta"),
            )
          ],
        ),
      ),
    );
  }
}
