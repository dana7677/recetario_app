import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:recetario_app/appFolder/lista_recetas.dart';


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




class RecetaDetails extends StatelessWidget {

 final RecetaModel receta;

  final double proteinas = 25;
  final double carbohidratos = 50;
  final double grasas = 10;
  final double azucares = 15;
  List<String> get instrucciones => receta.instrucciones;
  List<String> get ingredientes => receta.ingredientes;

  const RecetaDetails({super.key, required this.receta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text(receta.titulo,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold))),
      body:Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Image.asset(
                  receta.urlImage,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 60,
                  child: Text(receta.description,style: TextStyle(fontSize: 18),)),
              ),
              SizedBox(
                height: 220,
                child: PieChart(PieChartData(
                  sections: [
                PieChartSectionData(
                  value: receta.valoresNutricional.proteinas,
                  color: Colors.green,
                  title: 'Proteínas\n${receta.valoresNutricional.proteinas}g',
                  radius: 50,
                  titleStyle: TextStyle(fontSize: 12, color: Colors.white),
                ),
              PieChartSectionData(
                value: receta.valoresNutricional.carbohidratos,
                color: Colors.orange,
                title: 'Carbos\n${receta.valoresNutricional.carbohidratos}g',
                radius: 50,
                titleStyle: TextStyle(fontSize: 12, color: Colors.white),
              ),
              PieChartSectionData(
                value: receta.valoresNutricional.grasas,
                color: Colors.red,
                title: 'Grasas\n${receta.valoresNutricional.grasas}g',
                radius: 50,
                titleStyle: TextStyle(fontSize: 12, color: Colors.white),
              ),
              PieChartSectionData(
                value: receta.valoresNutricional.azucares,
                color: Colors.purple,
                title: 'Azúcares\n${receta.valoresNutricional.azucares}g',
                radius: 50,
                titleStyle: TextStyle(fontSize: 12, color: Colors.white),
              ),
                  ]
                )),
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