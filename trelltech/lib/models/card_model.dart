import 'package:flutter/material.dart';

class CardModel {
  String name;

  CardModel({
    required this.name,
  });

  static List<CardModel> getCard() {
    return [
      CardModel(name: 'Card 1'),
      CardModel(name: 'Card 2'),
      CardModel(name: 'Card 3'),
    ];
  }

  String getName() {
    return name;
  }
}
