class BoardModel {
  String name;
  String id;

  BoardModel({
    required this.id,
    required this.name,
  });

  String getName() {
    return name;
  }

  String getId() {
    return id;
  }

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
