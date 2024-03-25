class MemberModel {
  String name;
  String id;
  String initials;

  MemberModel({
    required this.name,
    required this.id,
    required this.initials,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      name: json['fullName'],
      id: json['id'],
      initials: json['initials'],
    );
  }
}
