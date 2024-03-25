class CardModel {
  String name;
  String id;
  String desc;
  List<String> idMembers; // Add this property

  CardModel({
    required this.name,
    required this.id,
    required this.desc,
    required this.idMembers, // Initialize it in the constructor
  });

  String getName() {
    return name;
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      name: json['name'],
      id: json['id'],
      desc: json['desc'],
      idMembers: List<String>.from(json['idMembers'] ?? []),
    );
  }
}
