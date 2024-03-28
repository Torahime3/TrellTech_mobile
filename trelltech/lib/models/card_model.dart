class CardModel {
  String name;
  String id;
  String desc;
  String startDate;
  String dueDate;

  CardModel({
    required this.name,
    required this.id,
    required this.desc,
    this.startDate = '',
    this.dueDate = '',
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
    );
  }
}
