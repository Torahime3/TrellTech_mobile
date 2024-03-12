class CardModel {
  String name;
  String id;

  CardModel({
    required this.name,
    required this.id,
  });

  /*static List<CardModel> getCard() {
    return [
      CardModel(name: 'This text is taking 1 line'),
      CardModel(name: 'This text is taking 2 lines aaaaaaaaaaaaaaaaaaaaaaaa'),
      CardModel(
          name:
              'This text is taking 3 lines aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
      CardModel(
          name:
              'This text is taking 4 lines aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
      CardModel(name: 'Card 3'),
      CardModel(name: 'Card 3'),
      CardModel(name: 'Card 3'),
      CardModel(name: 'Card 3'),
      CardModel(name: 'Card 3'),
      CardModel(name: 'Card 3'),
      CardModel(name: 'Card 3'),
      CardModel(name: 'Card 3'),
    ];
  }*/

  String getName() {
    return name;
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      name: json['name'],
      id: json['id'],
    );
  }
}
