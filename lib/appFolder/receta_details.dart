
import 'package:recetario_app/appFolder/lista_recetas.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';


class IngredienteItem extends StatelessWidget{
  final String ingrediente;
  final  int position;

  const IngredienteItem({
    super.key,
    required this.ingrediente,
    required this.position
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(" - ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
            Text(ingrediente,style: TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }
}

class InstruccionItem extends StatelessWidget{
  final String instruccion;
  final  int position;

  const InstruccionItem({
    super.key,
    required this.instruccion,
    required this.position
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$position- ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
            Text(instruccion,style: TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }
}
class GraficaNutricional extends StatelessWidget {
  final double proteinas;
  final double carbohidratos;
  final double grasas;
  final double azucares;
  final GlobalKey graficaKey; // Clave para capturar la imagen

  const GraficaNutricional({
    super.key,
    required this.proteinas,
    required this.carbohidratos,
    required this.grasas,
    required this.azucares,
    required this.graficaKey,
  });

  @override
  Widget build(BuildContext context) {
    // Retornamos un widget completo para que no dé error
    return RepaintBoundary(
      key: graficaKey,
      child: Container(
        padding: EdgeInsets.all(16),
        height: 220,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: proteinas,
                color: Colors.green,
                title: 'Proteínas\n${proteinas}g',
                radius: 50,
                titleStyle: TextStyle(fontSize: 12, color: Colors.white),
              ),
              PieChartSectionData(
                value: carbohidratos,
                color: Colors.orange,
                title: 'Carbos\n${carbohidratos}g',
                radius: 50,
                titleStyle: TextStyle(fontSize: 12, color: Colors.white),
              ),
              PieChartSectionData(
                value: grasas,
                color: Colors.red,
                title: 'Grasas\n${grasas}g',
                radius: 50,
                titleStyle: TextStyle(fontSize: 12, color: Colors.white),
              ),
              PieChartSectionData(
                value: azucares,
                color: Colors.purple,
                title: 'Azúcares\n${azucares}g',
                radius: 50,
                titleStyle: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class RecetaDetails extends StatelessWidget {

 final RecetaModel receta;

  final double proteinas = 25;
  final double carbohidratos = 50;
  final double grasas = 10;
  final double azucares = 15;
  List<String> get instrucciones => receta.instrucciones;
  List<String> get ingredientes => receta.ingredientes;
  final GlobalKey _graficaKey = GlobalKey();

Future<void> compartirRecetaConImagen(RecetaModel receta) async {
    // 1️⃣ Copiar imagen de receta (asset o local)
  XFile fileImagen;
  if (receta.urlImage.startsWith('/')) {
    // Es un archivo local
    fileImagen = XFile(receta.urlImage);
  } else {
    // Es un asset, copiar a temp
    final byteData = await rootBundle.load(receta.urlImage);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${receta.titulo}.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    fileImagen = XFile(file.path);
  }

  // 3️⃣ Texto de la receta
  final textoReceta = '''
🍳 ${receta.titulo}

${receta.description}

Ingredientes:
${receta.ingredientes.map((e) => "- $e").join('\n')}

Instrucciones:
${receta.instrucciones.asMap().entries.map((e) => "${e.key + 1}️⃣ ${e.value}").join('\n')}

⏱ Tiempo: ${receta.tiempo} min
⭐ Calificación: ${receta.stars}
''';
/*
  // 2️⃣ Capturar gráfica como imagen
  final boundary = _graficaKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  final tempDir = await getTemporaryDirectory();
  final graficaFile = File('${tempDir.path}/grafica_${receta.titulo}.png');
  await graficaFile.writeAsBytes(pngBytes);
  final fileGrafica = XFile(graficaFile.path);
*/

  // 4️⃣ Compartir con SharePlus
  await SharePlus.instance.share(
    ShareParams(
      text: textoReceta,
      files: [fileImagen], // ✅ ahora comparte foto + gráfica faltaria agregar el fileGrafica pero queda feo
    ),
  );
}


  RecetaDetails({super.key, required this.receta});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text(receta.titulo,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),actions: [
        IconButton(onPressed:() => compartirRecetaConImagen(receta), icon: Icon(Icons.share))
      ],),
      body:Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: 300,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 60,
                  child: Text(receta.description,style: TextStyle(fontSize: 18),)),
              ),
              SizedBox(
                height: 220,
                child: GraficaNutricional(
                proteinas: receta.valoresNutricional.proteinas,
                carbohidratos: receta.valoresNutricional.carbohidratos,
                grasas: receta.valoresNutricional.grasas,
                azucares: receta.valoresNutricional.azucares,
                graficaKey: _graficaKey,
              ),
              ), 
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    children: [
                      Container(

                        alignment: Alignment.topLeft,
                        child: Text("Ingredientes:",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,decoration: TextDecoration.underline),textAlign: TextAlign.left)
                      ),
                      
                      Column(
                        children: List.generate(
                          receta.ingredientes.length,
                          (index) => IngredienteItem(
                            ingrediente: receta.ingredientes[index],
                            position: index + 1,
                          ),
                        ),
                      )

                      
                    ],
                  ),
                ),
              )
              ,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    children: [
                      Container(

                        alignment: Alignment.topLeft,
                        child: Text("Instrucciones:",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,decoration: TextDecoration.underline),textAlign: TextAlign.left)
                      ),
                      
                      Column(
                        children: List.generate(
                          receta.instrucciones.length,
                          (index) => InstruccionItem(
                            instruccion: receta.instrucciones[index],
                            position: index + 1,
                          ),
                        ),
                      )

                      
                    ],
                  ),
                ),
              )
            

            ],
          ),
        ),
      ),
    )
    );
    
  }
}