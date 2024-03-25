
class Workspace {
  String id;

  Workspace({
    required this.id
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      // name: json['name'],
      // Initialize other properties from JSON
    );
  }
}