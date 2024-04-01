import 'package:flutter/material.dart';

class MemberModel {
  String name;
  String id;
  String? initials;
  Color? color;
  List<String> cardIds;

  MemberModel({
    required this.name,
    required this.id,
    this.initials,
    this.color,
    required this.cardIds,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      name: json['fullName'],
      id: json['id'],
      initials: '',
      color: null,
      cardIds: [],
    );
  }
}
