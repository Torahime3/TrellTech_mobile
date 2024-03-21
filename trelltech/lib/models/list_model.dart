class ListModel {
  String name;
  String id;

  ListModel({required this.name, required this.id});

  String getName() {
    return name;
  }

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      name: json['name'],
      id: json['id'],
    );
  }
}
