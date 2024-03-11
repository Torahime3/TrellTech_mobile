import 'package:flutter/material.dart';

AppBar appbar({dynamic text = "TrellTech", color = Colors.transparent}) {
  return AppBar(
    title: Text(text,
        style: const TextStyle(
          color: Color.fromARGB(255, 34, 34, 34),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        )),
    centerTitle: true,
    backgroundColor: color,
    elevation: 0,
  );
}
