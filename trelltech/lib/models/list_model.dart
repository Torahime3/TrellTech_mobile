import 'package:trelltech/controllers/list_controller.dart';

class ListModel {
  String name;
  String id;
  double pos;

  ListModel({required this.name, required this.id, this.pos = 0});

  String getName() {
    return name;
  }

  String getId() {
    return id;
  }

  double getPos() {
    return pos;
  }

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      name: json['name'],
      id: json['id'],
      pos: double.parse(json['pos'].toString()),
    );
  }

  void moveListBetween(ListModel firstList, ListModel secondList) {
    ListController lc = ListController();
    int newPos = ((firstList.pos + secondList.pos) / 2).ceil();
    lc.update(id: id, name: name, pos: newPos);
  }
}
