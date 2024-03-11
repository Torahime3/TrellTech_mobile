// import 'package:flutter/material.dart';

class BoardModel {
  String name;
  // Color color;
  String id;

  BoardModel({
    required this.id,
    required this.name,
    // required this.color,
  });

  // static List<BoardModel> getBoards() {
  //   return <BoardModel>[
  //     BoardModel(name: 'Board 1', color: Colors.blue),
  //     BoardModel(name: 'Board 2', color: Colors.red),
  //     BoardModel(name: 'Board 3', color: Colors.green),
  //     BoardModel(name: 'Board 4', color: Colors.yellow),
  //     BoardModel(name: 'Board 5', color: Colors.purple),
  //   ];
  // }

  String getName() {
    return name;
  }

  // Color getColor() {
  //   return color;
  // }

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json['id'],
      name: json['name'],
      // Initialize other properties from JSON
    );
  }
}
