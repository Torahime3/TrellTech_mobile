class MemberModel {
  String name;
  String id;
  String? initials;
  List<String> cardIds; // Updated field to store list of card IDs

  MemberModel({
    required this.name,
    required this.id,
    this.initials,
    required this.cardIds, // Update the constructor
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      name: json['fullName'],
      id: json['id'],
      initials: '',
      cardIds: [], // Initialize cardIds list
    );
  }
}
