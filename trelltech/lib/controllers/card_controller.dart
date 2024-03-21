import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trelltech/models/card_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/storage/authtoken_storage.dart';

class CardController {
  late final http.Client client;
  late final AuthTokenStorage _authTokenStorage;

  final String? apiKey = dotenv.env['API_KEY'];

  CardController({http.Client? client, AuthTokenStorage? authTokenStorage}) {
    this.client = client ?? http.Client();
    _authTokenStorage = authTokenStorage ?? AuthTokenStorage();
  }

  Future<String?> getApiToken() async {
    return await _authTokenStorage.getAuthToken();
  }

  Future<List<CardModel>> getCards({required ListModel list}) async {
    String apiToken = (await getApiToken())!;
    final String id = list.id;
    final url = Uri.parse(
        "https://api.trello.com/1/lists/$id/cards?key=$apiKey&token=$apiToken");

    final response = await client.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      List<CardModel> card = List<CardModel>.from(
          jsonResponse.map((cardJson) => CardModel.fromJson(cardJson)));
      return card;
    } else {
      throw Exception("No card found");
    }
  }

  Future<CardModel> create(listId, value) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/cards?idList=$listId&key=$apiKey&token=$apiToken&name=$value');
    final response = await client.post(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return CardModel.fromJson(jsonResponse);
    } else {
      throw Exception("No card created");
    }
  }

  Future<CardModel> update(cardId, value) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken&name=$value');
    final response = await client.put(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return CardModel.fromJson(jsonResponse);
    } else {
      throw Exception("Board not updated");
    }
  }

  Future<bool> delete(cardId) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken');
    final response = await client.delete(url);

    if (response.statusCode == 200) {
      return true;
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