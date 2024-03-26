class MemberModel {
  String name;
  String id;
  String initials;
  bool assigned;

  MemberModel({
    required this.name,
    required this.id,
    required this.initials,
    required this.assigned,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
        name: json['fullName'],
        id: json['id'],
        initials: json['initials'],
        assigned: json['assigned']);
  }
}
