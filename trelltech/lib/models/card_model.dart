class CardModel {
  String name;
  String id;

  CardModel({
    required this.name,
    required this.id,
  });

  String getName() {
    return name;
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      name: json['name'],
      id: json['id'],
    );
  }
}
