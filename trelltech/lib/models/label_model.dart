class LabelModel {
  String idboard;
  String name;
  String color;

  LabelModel({
    required this.idboard,
    required this.name,
    required this.color,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    return LabelModel(
      idboard: json['idBoard'],
      name: json['name'],
      color: json['color'],
    );
  }
}
