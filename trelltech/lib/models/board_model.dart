class BoardModel {
  String name;
  String id;
  final List<String> memberIds;

  BoardModel({
    required this.id,
    required this.name,
    required this.memberIds,
  });

  String getName() {
    return name;
  }

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> membershipsJson = json['memberships'];
    List<String> memberIds = membershipsJson
        .map((member) => member['idMember'].toString()) // Cast to String
        .toList();

    return BoardModel(
      id: json['id'],
      name: json['name'],
      memberIds: memberIds,
    );
  }
}
