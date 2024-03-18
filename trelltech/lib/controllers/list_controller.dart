import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trelltech/models/board_model.dart';
import 'package:trelltech/models/list_model.dart';
import 'package:trelltech/storage/authtoken_storage.dart';

class ListController {
  final String? apiKey = dotenv.env['API_KEY'];

  Future<String?> getApiToken() async {
    return await AuthTokenStorage.getAuthToken();
  }

  Future<List<ListModel>> getLists({required BoardModel board}) async {
    String apiToken = (await getApiToken())!;
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

  void create(String name,
      {required BoardModel board, void Function()? onCreated}) async {
    String apiToken = (await getApiToken())!;
    String id = board.id;
    final url = Uri.parse(
        'https://api.trello.com/1/lists?name=$name&idBoard=$id&key=$apiKey&token=$apiToken');

    final response = await http.post(
      url,
      body: {
        'pos': 'bottom',
      },
    );

    if (response.statusCode == 200) {
      print("List Created Successfully");
      if (onCreated != null) {
        onCreated();
      }
    } else {
      throw Exception("No List created");
    }
  }

  void update({required id, required name, void Function()? onUpdated}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        'https://api.trello.com/1/lists/$id?key=$apiKey&token=$apiToken');

    final response = await http.put(
      url,
      body: {
        'name': name,
      },
    );

    if (response.statusCode == 200) {
      print("List Updated Successfully");
      if (onUpdated != null) {
        onUpdated();
      }
    } else {
      throw Exception("List Update failed");
    }
  }

  void delete({required id, void Function()? onDeleted}) async {
    String apiToken = (await getApiToken())!;
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
      if (onDeleted != null) {
        onDeleted();
      }
    } else {
      throw Exception("List Deletion failed");
    }
  }
}
