import 'package:flutter/material.dart';

AppBar appbar({dynamic text = "TrellTech", color = Colors.blue}) {
  return AppBar(
    title: Text(text,
        style: TextStyle(
          color: Color.fromARGB(255, 34, 34, 34),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        )),
    centerTitle: true,
    backgroundColor: color,
  );
}
