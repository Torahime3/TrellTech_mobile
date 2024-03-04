import 'package:flutter/material.dart';

void main(){

  runApp(TrellTech());

}

class TrellTech extends StatelessWidget{
  const TrellTech({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TrellTech'),
          backgroundColor: Colors.blue,
        ),
        
      )
    );
  }
}