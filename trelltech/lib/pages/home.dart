import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
    );
  }


  AppBar appbar(){
    return AppBar(
        title: const Text('TrellTech', 
        style: TextStyle(
          color: Color.fromARGB(255, 34, 34, 34),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        )),
        centerTitle: true,
      );
  }
}

