import 'package:flutter/material.dart';
import 'pages/home.dart';

void main(){
  runApp(const TrellTech());
}

class TrellTech extends StatelessWidget{
  const TrellTech({super.key});

  @override
  Widget build(BuildContext context){
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}