class CardModel {
  String name;
  String id;
  String desc;

  CardModel({
    required this.name,
    required this.id,
    required this.desc,
  });

  String getName() {
    return name;
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      name: json['name'],
      id: json['id'],
      desc: json['desc'],
    );
  }
}
