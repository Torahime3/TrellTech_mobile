import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/storage/authtoken_storage.dart';

class BoardController {
  final String? apiKey = dotenv.env['API_KEY'];
  final String id = "trelltech12";

  Future<String?> getApiToken() async {
    return await AuthTokenStorage.getAuthToken();
  }

  Future<List<BoardModel>> getBoards() async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        "https://api.trello.com/1/members/$id/boards?key=$apiKey&token=$apiToken");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List<BoardModel> boards = List<BoardModel>.from(
          jsonResponse.map((boardJson) => BoardModel.fromJson(boardJson)));
      return boards;
    } else {
      throw Exception("No boards");
    }
  }

  void create({required name, void Function()? onCreated}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/boards/?name=$name&key=$apiKey&token=$apiToken');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      print("Hurray");
      if (onCreated != null) {
        onCreated();
      }
    } else {
      throw Exception("No board created");
    }
  }

  void update({required id, required name, void Function()? onUpdated}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/boards/$id?key=$apiKey&token=$apiToken&name=$name');
    final response = await http.put(url);
    if (response.statusCode == 200) {
      print("Updated");
      if (onUpdated != null) {
        onUpdated();
      }
    } else {
      throw Exception("Board not updated");
    }
  }

  void delete({required id, void Function()? onDeleted}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/boards/$id?key=$apiKey&token=$apiToken');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Deleted");
      if (onDeleted != null) {
        onDeleted();
      }
    } else {
      throw Exception("Board not deleted");
    }
  }
}
