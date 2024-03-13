import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/list_model.dart';

class ListController {
  final String apiKey = "31b42a669dfa82bfba4203e7b18d6f6e";
  final String apiToken =
      "ATTAea00fc54136551cffd8859f79e8e8482654a2c96ac980e1c8885af35ccd2a877D08B7C23";

  Future<List<ListModel>> getLists({required BoardModel board}) async {
    String id = board.id;
    final url = Uri.parse(
        "https://api.trello.com/1/boards/$id/lists?key=$apiKey&token=$apiToken");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      List<ListModel> list = List<ListModel>.from(
          jsonResponse.map((listJson) => ListModel.fromJson(listJson)));
      return list;
    } else {
      throw Exception("No list found");
    }
  }

  void create(name, {required BoardModel board}) async {
    String id = board.id;
    final url = Uri.parse(
        'https://api.trello.com/1/lists?name=$name&idBoard=$id&key=$apiKey&token=$apiToken');

    final response = await http.post(url);

    if (response.statusCode == 200) {
      print("List Created Successfully");
    } else {
      throw Exception("No List created");
    }
  }

  void delete({required id}) async {
    final url = Uri.parse(
        'https://api.trello.com/1/lists/$id/closed?key=$apiKey&token=$apiToken');

    final response = await http.put(
      url,
      body: {
        'value': 'true',
      },
    );

    if (response.statusCode == 200) {
      print("List Deleted Successfully");
    } else {
      throw Exception("List Deletion failed");
    }
  }
}
