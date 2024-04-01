// ignore_for_file: avoid_print

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

  Future<List<CardModel>> getCardDetails({required CardModel card}) async {
    String apiToken = (await getApiToken())!;
    final String id = card.id;
    final url = Uri.parse(
        "https://api.trello.com/1/cards/$id?key=$apiKey&token=$apiToken");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      // Map the JSON response to a List<CardModel>
      List<CardModel> cardDetails = [CardModel.fromJson(jsonResponse)];

      return cardDetails;
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

  Future<CardModel> update(
      {String? cardId,
      String? name,
      String? startDate,
      String? dueDate}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken');

    Map<String, dynamic> body = {};

    if (name != null) {
      body['name'] = name;
    }

    if (startDate != null && startDate.isNotEmpty) {
      body['start'] = startDate;
    }

    if (dueDate != null) {
      body['due'] = dueDate;
      body['dueComplete'] = true;
    }

    final response = await client.put(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return CardModel.fromJson(jsonResponse);
    } else {
      throw Exception("Card not updated");
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
    final url = Uri.parse(
        'https://api.trello.com/1/cards/$cardId/name?key=$apiKey&token=$apiToken');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Does the same thing
      // Map<String, dynamic> jsonRes = json.decode(response.body);
      // print(jsonRes['_value']);
      return jsonResponse['_value'];
    } else {
      throw Exception("Board not deleted");
    }
  }

  void updateDesc(
      {required id, required desc, void Function()? onUpdated}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/cards/$id?key=$apiKey&token=$apiToken');

    final response = await http.put(
      url,
      body: {
        'desc': desc,
      },
    );

    if (response.statusCode == 200) {
      //print("Description Updated Successfully");
      if (onUpdated != null) {
        onUpdated();
      }
    } else {
      throw Exception("Description Update failed");
    }
  }

  Future<void> addMemberToCard({
    required String memberId,
    required String cardId,
    void Function()? onAdded,
  }) async {
    String apiToken = (await getApiToken())!;
    try {
      final url = Uri.parse(
          'https://api.trello.com/1/cards/$cardId/idMembers?key=$apiKey&token=$apiToken');

      final response = await http.post(
        url,
        body: {
          'value': memberId,
        },
      );

      if (response.statusCode == 200) {
        // Successful update, trigger the onUpdated callback if provided
        if (onAdded != null) {
          onAdded();
        }
      } else {
        // Handle other status codes, such as 400 for bad request
        throw Exception(
            'Failed to add member to card: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle any exceptions, such as network errors
      throw Exception('Failed to add member to card: $e');
    }
  }

  Future<void> removeMemberFromCard({
    required String memberId,
    required String cardId,
    void Function()? onDeleted,
  }) async {
    String apiToken = (await getApiToken())!;
    try {
      final url = Uri.parse(
          'https://api.trello.com/1/cards/$cardId/idMembers/$memberId?key=$apiKey&token=$apiToken');

      final response = await http.delete(
        url,
      );

      if (response.statusCode == 200) {
        // Successful update, trigger the onUpdated callback if provided
        if (onDeleted != null) {
          onDeleted();
        }
      } else {
        // Handle other status codes, such as 400 for bad request
        throw Exception(
            'Failed to remove member from card: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle any exceptions, such as network errors
      throw Exception('Failed to remove member from card: $e');
    }
  }
}
