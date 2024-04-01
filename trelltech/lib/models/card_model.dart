import 'package:trelltech/models/label_model.dart';

class CardModel {
  String name;
  String id;
  String desc;
  String startDate;
  String dueDate;
  String coverColor;
  List<LabelModel> label;

  CardModel({
    required this.name,
    required this.id,
    required this.desc,
    this.startDate = '',
    this.dueDate = '',
    this.coverColor = 'white',
    this.label = const [],
  });

  String getName() {
    return name;
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      name: json['name'],
      id: json['id'],
      desc: json['desc'],
      startDate: json['start'] ?? '',
      dueDate: json['due'] ?? '',
      coverColor: json['cover']?['color'] ?? '',
      label: (json['labels'] as List)
          .map((label) => LabelModel.fromJson(label))
          .toList(),
    );
  }
}
