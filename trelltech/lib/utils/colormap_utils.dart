import 'package:flutter/material.dart';

Map<String, Color> colorMap = {
  'green': Colors.green,
  'yellow': Colors.yellow,
  'orange': Colors.orange,
  'red': const Color.fromARGB(255, 255, 17, 0),
  'purple': Colors.purple,
  'blue': const Color.fromARGB(255, 13, 67, 245),
  'sky': Colors.lightBlue,
  'lime': const Color.fromARGB(255, 125, 243, 101),
  'pink': const Color.fromARGB(255, 233, 75, 135),
  'black': Colors.grey,
  'purple_dark': Colors.deepPurple,
};

Color getColorFromString(String colorName) {
  return colorMap[colorName.toLowerCase()] ?? Colors.transparent;
}
