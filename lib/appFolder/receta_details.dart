
import 'package:recetario_app/appFolder/lista_recetas.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';


//Widget de ingrediente
class IngredienteItem extends StatefulWidget {
  final String ingrediente;
  final int position;

  const IngredienteItem({
    super.key,
    required this.ingrediente,
    required this.position,
  });

  @override
  State<IngredienteItem> createState() => _IngredienteItemState();
}

class _IngredienteItemState extends State<IngredienteItem> {
  bool loTengo = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          HapticFeedback.lightImpact();
          loTengo = !loTengo;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: loTengo ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: loTengo ? Colors.green : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              loTengo ? Icons.check_circle : Icons.radio_button_unchecked,
              color: loTengo ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.ingrediente,
                style: TextStyle(
                  fontSize: 18,
                  decoration:
                      loTengo ? TextDecoration.lineThrough : TextDecoration.none,
                  color: loTengo ? Colors.green.shade800 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de Instrucción
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

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.orange,
          child: Text("$position",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
        ),
        SizedBox(width: 12),
        Expanded(child: Text(instruccion,style: TextStyle(fontSize: 20))),
      ],
    ),
  );
  }
}

// Widget de la gráfica nutricional
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
        height: 200,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: proteinas,
                color: Colors.green,
                title: "",//'Proteínas\n${proteinas}g',
                radius: 50,
                titleStyle: TextStyle(fontSize: 11, color: Colors.white),
              ),
              PieChartSectionData(
                value: carbohidratos,
                color: Colors.orange,
                title: "",//'Carbos\n${carbohidratos}g',
                radius: 50,
                titleStyle: TextStyle(fontSize: 11, color: Colors.white),
              ),
              PieChartSectionData(
                value: grasas,
                color: Colors.red,
                title: "",//'Grasas\n${grasas}g',
                radius: 50,
                titleStyle: TextStyle(fontSize: 11, color: Colors.white),
              ),
              PieChartSectionData(
                value: azucares,
                color: Colors.purple,
                title: "",//'Azúcares\n${azucares}g',
                radius: 50,
                titleStyle: TextStyle(fontSize: 11, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Widget de la receta
class RecetaDetails extends StatelessWidget {

 final RecetaModel receta;

  double get proteinas => receta.valoresNutricional.proteinas;
  double get carbohidratos => receta.valoresNutricional.carbohidratos;
  double get grasas => receta.valoresNutricional.grasas;
  double get azucares => receta.valoresNutricional.azucares;
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
  // No lo uso pero dejo comentado , por si se usa en un futuro, convertimos la grafica a imagen para poder compartirla.
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
      appBar: AppBar(title:  Container(alignment: Alignment.center, child: Text("¿ Que cocinamos hoy ?",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,))),backgroundColor:const Color.fromARGB(255, 253, 249, 239)
        ,actions: [
        IconButton(onPressed:() => compartirRecetaConImagen(receta), icon: Icon(Icons.share))
      ],),
      backgroundColor:Color.fromARGB(255, 253, 249, 239),
      body:Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(20),
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
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.transparent,Colors.black87],
                      begin: Alignment.topCenter,
                      end:Alignment.bottomCenter)
                    ),
                  ))
              ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 60,
                  child: Text(receta.description,style: TextStyle(fontSize: 18),)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    children: [
                      Container(

                        alignment: Alignment.topLeft,
                        child: Text("Ingredientes:",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left)
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
                        child: Text("Instrucciones:",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left)
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
              ,
              Card(
                elevation: 6,
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    height: 335,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text("Información nutricional",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left)),
                        GraficaNutricional(
                        proteinas: receta.valoresNutricional.proteinas,
                        carbohidratos: receta.valoresNutricional.carbohidratos,
                        grasas: receta.valoresNutricional.grasas,
                        azucares: receta.valoresNutricional.azucares,
                        graficaKey: _graficaKey,
                        ),
                        Container(
                          width: 140,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text("🔴 Grasas ${receta.valoresNutricional.grasas}",style: TextStyle(fontSize: 17))),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text("🟢 Proteínas ${receta.valoresNutricional.proteinas}",style: TextStyle(fontSize: 17))),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text("🟠 Carbos ${receta.valoresNutricional.carbohidratos}",style: TextStyle(fontSize: 17))),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text("🟣 Azúcares ${receta.valoresNutricional.azucares}",style: TextStyle(fontSize: 17))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ), 
            ],
          ),
        ),
      ),
    )
    );
    
  }
}