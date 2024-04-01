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

  Future<List<BoardModel>> getBoardsInWorkspace(id) async {
    String apiToken = (await getApiToken())!;

    final url = Uri.parse('https://api.trello.com/1/organizations/$id/boards?key=$apiKey&token=$apiToken');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List<BoardModel> boards = List<BoardModel>.from(
        jsonResponse.map((boardJson) => BoardModel.fromJson(boardJson))
      );
      return boards;
    } else {
      throw Exception("No boards");
    }
  }

  Future<BoardModel> create({required name, id, void Function()? onCreated}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/boards/?name=$name&key=$apiKey&token=$apiToken&idOrganization=$id');
    final response = await client.post(url);

    if (response.statusCode == 200) {
      if (onCreated != null) {
        onCreated();
      }
      final jsonResponse = jsonDecode(response.body);
      return BoardModel.fromJson(jsonResponse);
    } else {
      throw Exception("No board created");
    }
  }

  Future<bool> createTemplate(name, id, idBoardSource) async {
    String apiToken = (await getApiToken())!;

    final url = Uri.parse('https://api.trello.com/1/boards/?name=$name&key=$apiKey&token=$apiToken&idOrganization=$id&idBoardSource=$idBoardSource');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Board not created");
    }
  }

  Future<BoardModel> update(
      {required id, required name, void Function()? onUpdated}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/boards/$id?key=$apiKey&token=$apiToken&name=$name');
    final response = await client.put(url);
    if (response.statusCode == 200) {
      if (onUpdated != null) {
        onUpdated();
      }
      final jsonResponse = jsonDecode(response.body);
      return BoardModel.fromJson(jsonResponse);
    } else {
      throw Exception("Board not updated");
    }
  }

  Future<bool> delete({required id, void Function()? onDeleted}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/boards/$id?key=$apiKey&token=$apiToken');
    final response = await client.delete(url);

    if (response.statusCode == 200) {
      if (onDeleted != null) {
        onDeleted();
      }
      return true;
    } else {
      throw Exception("Board not deleted");
    }
  }
}
