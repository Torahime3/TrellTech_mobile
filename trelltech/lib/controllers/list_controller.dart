import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/storage/authtoken_storage.dart';

class ListController {
  late final http.Client client;
  late final AuthTokenStorage _authTokenStorage;

  final String? apiKey = dotenv.env['API_KEY'];

  ListController({http.Client? client, AuthTokenStorage? authTokenStorage}) {
    this.client = client ?? http.Client();
    _authTokenStorage = authTokenStorage ?? AuthTokenStorage();
  }

  Future<String?> getApiToken() async {
    return await _authTokenStorage.getAuthToken();
  }

  Future<List<ListModel>> getLists({required BoardModel board}) async {
    String apiToken = (await getApiToken())!;
    String id = board.id;
    final url = Uri.parse(
        "https://api.trello.com/1/boards/$id/lists?key=$apiKey&token=$apiToken");

    final response = await client.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      List<ListModel> list = List<ListModel>.from(
          jsonResponse.map((listJson) => ListModel.fromJson(listJson)));
      return list;
    } else {
      throw Exception("No list found");
    }
  }

  Future<ListModel> create(String name,
      {required BoardModel board, void Function()? onCreated}) async {
    String apiToken = (await getApiToken())!;
    String id = board.id;
    final url = Uri.parse(
        'https://api.trello.com/1/lists?name=$name&idBoard=$id&key=$apiKey&token=$apiToken');

    final response = await client.post(
      url,
      body: {
        'pos': 'bottom',
      },
    );

    if (response.statusCode == 200) {
      if (onCreated != null) {
        onCreated();
      }

      final jsonResponse = jsonDecode(response.body);
      return ListModel.fromJson(jsonResponse);
    } else {
      throw Exception("No List created");
    }
  }

  Future<ListModel> update(
      {required id,
      required name,
      int? pos,
      void Function()? onUpdated}) async {
    String apiToken = (await getApiToken())!;

    final url = Uri.parse(
        'https://api.trello.com/1/lists/$id?key=$apiKey&token=$apiToken');

    final http.Response response;
    if (pos != null) {
      response = await client.put(
        url,
        body: {
          'name': name,
          'pos': pos.toString(),
        },
      );
    } else {
      response = await client.put(
        url,
        body: {
          'name': name,
        },
      );
    }

    if (response.statusCode == 200) {
      if (onUpdated != null) {
        onUpdated();
      }
      final jsonResponse = jsonDecode(response.body);
      return ListModel.fromJson(jsonResponse);
    } else {
      throw Exception("List Update failed");
    }
  }

  Future<bool> delete({required id, void Function()? onDeleted}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/lists/$id/closed?key=$apiKey&token=$apiToken');

    final response = await client.put(
      url,
      body: {
        'value': 'true',
      },
    );

    if (response.statusCode == 200) {
      if (onDeleted != null) {
        onDeleted();
      }
      return true;
    } else {
      throw Exception("List Deletion failed");
    }
  }
}
