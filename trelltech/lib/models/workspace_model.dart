
class Workspace {
  String id;
  bool isExpanded;

  Workspace({
    required this.id,
    this.isExpanded = false,
  });

  bool getIsExpanded() {
    return isExpanded;
  }

  void toggleExpansion() {
    isExpanded = !isExpanded;
  }
  
  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      // name: json['name'],
      // Initialize other properties from JSON
    );
  }
}