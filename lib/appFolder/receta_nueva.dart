import 'package:flutter/material.dart';


class RecetaNueva extends StatelessWidget {
    RecetaNueva({super.key});

    double porcentaje = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(body:Center
    (child:Container(
      child: Text("¡Bienvenido a Flutter!",
      style:TextStyle(fontSize: 24,color: Colors.blue,fontWeight: FontWeight.bold))
    ))
    );
    
  }
}