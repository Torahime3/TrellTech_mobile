
class Workspace {
  String id;
  String displayName;
  bool isExpanded;

  Workspace({
    required this.id,
    required this.displayName,
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
      displayName: json['displayName'],
      // Initialize other properties from JSON
    );
  }
}