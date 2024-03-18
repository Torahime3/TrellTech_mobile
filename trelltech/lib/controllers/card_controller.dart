import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/storage/authtoken_storage.dart';

class CardController {
  final String? apiKey = dotenv.env['API_KEY'];

  Future<String?> getApiToken() async {
    return await AuthTokenStorage.getAuthToken();
  }

  Future<List<CardModel>> getCards({required ListModel list}) async {
    String apiToken = (await getApiToken())!;
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
