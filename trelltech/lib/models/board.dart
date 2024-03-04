import 'package:flutter/material.dart';

class BoardModel {
  String name;

  BoardModel({required this.name});

  static List<BoardModel> getBoards() {
    return <BoardModel>[
      BoardModel(name: 'Board 1'),
      BoardModel(name: 'Board 2'),
      BoardModel(name: 'Board 3'),
      BoardModel(name: 'Board 4'),
      BoardModel(name: 'Board 5'),
    ];
  }

  String getName() {
    return name;
  }
}
