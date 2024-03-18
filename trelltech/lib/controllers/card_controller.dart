import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/list_model.dart';

class CardController {
  final String apiKey = "31b42a669dfa82bfba4203e7b18d6f6e";
  final String apiToken =
      "ATTAea00fc54136551cffd8859f79e8e8482654a2c96ac980e1c8885af35ccd2a877D08B7C23";

  Future<List<CardModel>> getCards({required ListModel list}) async {
    final String id = list.id;
    final url = Uri.parse(
        "https://api.trello.com/1/lists/$id/cards?key=$apiKey&token=$apiToken");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      List<CardModel> card = List<CardModel>.from(
          jsonResponse.map((cardJson) => CardModel.fromJson(cardJson)));
      return card;
    } else {
      throw Exception("No card found");
    }
  }
}
