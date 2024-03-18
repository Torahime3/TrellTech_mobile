import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trelltech/models/board_model.dart';
class BoardController {

  final String apiKey = "31b42a669dfa82bfba4203e7b18d6f6e";
  final String apiToken = "ATTAea00fc54136551cffd8859f79e8e8482654a2c96ac980e1c8885af35ccd2a877D08B7C23";
  final String id = "trelltech12";

  Future<List<BoardModel>> getBoards() async {
    
    final url = Uri.parse("https://api.trello.com/1/members/$id/boards?key=$apiKey&token=$apiToken");


    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // List<BoardModel> boards = jsonResponse.map((boardJson) => BoardModel.fromJson(boardJson)).toList();
      // return boards;

      List<BoardModel> boards = List<BoardModel>.from(jsonResponse.map((boardJson) => BoardModel.fromJson(boardJson)));
      return boards;
    } else {
      throw Exception("No boards");
    }
  }


  void create(name) async {
    final url = Uri.parse('https://api.trello.com/1/boards/?name=$name&key=$apiKey&token=$apiToken');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      print("Hurray");
    } else {
      throw Exception("No board created");
    }
  }

  void update(id, name) async {
    final url = Uri.parse('https://api.trello.com/1/boards/$id?key=$apiKey&token=$apiToken&name=$name');
    final response = await http.put(url);
    if (response.statusCode == 200) {
      print("Updated");
    } else {
      throw Exception("Board not updated");
    }
  }

  void delete(id) async {
    final url = Uri.parse('https://api.trello.com/1/boards/$id?key=$apiKey&token=$apiToken');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Deleted");
    } else {
      throw Exception("Board not deleted");
    }
  }
}


 