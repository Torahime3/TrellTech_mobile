class ListModel {
  String name;
  String id;

  ListModel({required this.name, required this.id});

  /*static List<ListModel> getList() {
    return [
      ListModel(name: 'To Do'),
      ListModel(name: 'In Progress'),
      ListModel(name: 'Done'),
      ListModel(name: 'To Do'),
      ListModel(name: 'In Progress'),
      ListModel(name: 'Done'),
      ListModel(name: 'To Do'),
      ListModel(name: 'In Progress'),
      ListModel(name: 'Done'),
    ];
  }*/

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
