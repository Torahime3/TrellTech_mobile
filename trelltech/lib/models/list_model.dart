class ListModel {
  String name;

  ListModel({
    required this.name,
  });

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
    );
  }
}
