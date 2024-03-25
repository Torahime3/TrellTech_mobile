class ListModel {
  String name;
  String id;
  int pos;

  ListModel({required this.name, required this.id, this.pos = 0});

  String getName() {
    return name;
  }

  String getId() {
    return id;
  }

  int getPos() {
    return pos;
  }

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      name: json['name'],
      id: json['id'],
      pos: json['pos'],
    );
  }
}
