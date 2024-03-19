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

  Future<void> create(listId, value) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/cards?idList=$listId&key=$apiKey&token=$apiToken&name=$value');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      print("Hurray Card created");
    } else {
      throw Exception("No card created");
    }
  }

  void update(cardId, value) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken&name=$value');
    final response = await http.put(url);
    if (response.statusCode == 200) {
      print("Updated");
    } else {
      throw Exception("Board not updated");
    }
  }

  void delete(cardId) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Deleted");
    } else {
      throw Exception("Board not deleted");
    }
  }

  Future<String> getCardName(cardId) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse('https://api.trello.com/1/cards/$cardId/name?key=$apiKey&token=$apiToken');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse['_value']);

      // Does the same thing
      // Map<String, dynamic> jsonRes = json.decode(response.body);
      // print(jsonRes['_value']);
      return jsonResponse['_value'];

    } else {
      throw Exception("Board not deleted");
    }
  }
}