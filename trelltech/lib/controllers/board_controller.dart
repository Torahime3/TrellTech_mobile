import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/storage/authtoken_storage.dart';

class BoardController {
  late final http.Client client;
  late final AuthTokenStorage _authTokenStorage;

  final String? apiKey = dotenv.env['API_KEY'];
  final String id = "trelltech12";

  BoardController({http.Client? client, AuthTokenStorage? authTokenStorage}) {
    this.client = client ?? http.Client();
    _authTokenStorage = authTokenStorage ?? AuthTokenStorage();
  }

  Future<String?> getApiToken() async {
    return await _authTokenStorage.getAuthToken();
  }

  Future<List<BoardModel>> getBoards() async {
    String apiToken = (await getApiToken())!;

    final url = Uri.parse(
        "https://api.trello.com/1/members/$id/boards?key=$apiKey&token=$apiToken");

    final response = await client.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List<BoardModel> boards = List<BoardModel>.from(
          jsonResponse.map((boardJson) => BoardModel.fromJson(boardJson)));
      return boards;
    } else {
      throw Exception("No boards");
    }
  }

  Future<BoardModel> create({required name, void Function()? onCreated}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/boards/?name=$name&key=$apiKey&token=$apiToken');
    final response = await client.post(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (onCreated != null) {
        onCreated();
      }

      return BoardModel.fromJson(jsonResponse);
    } else {
      throw Exception("No board created");
    }
  }

  Future<BoardModel> update(id, name) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/boards/$id?key=$apiKey&token=$apiToken&name=$name');
    final response = await client.put(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return BoardModel.fromJson(jsonResponse);
    } else {
      throw Exception("Board not updated");
    }
  }

  void delete(id) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/boards/$id?key=$apiKey&token=$apiToken');
    final response = await client.delete(url);

    if (response.statusCode == 200) {
      print("Deleted");
    } else {
      throw Exception("Board not deleted");
    }
  }
}
