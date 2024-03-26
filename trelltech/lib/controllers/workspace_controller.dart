import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trelltech/storage/authtoken_storage.dart';
import 'package:trelltech/models/workspace_model.dart';
import 'dart:convert';
class WorkspaceController {

  late final http.Client client;
  late final AuthTokenStorage _authTokenStorage;

  final String? apiKey = dotenv.env['API_KEY'];
  final String id = "trelltech12";

  WorkspaceController({http.Client? client, AuthTokenStorage? authTokenStorage}) {
    this.client = client ?? http.Client();
    _authTokenStorage = authTokenStorage ?? AuthTokenStorage();
  }

  Future<String?> getApiToken() async {
    return await _authTokenStorage.getAuthToken();
  }



  Future<List<Workspace>> get() async {
    String apiToken = (await getApiToken())!;

    final url = Uri.parse('https://api.trello.com/1/members/$id/organizations?key=$apiKey&token=$apiToken');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List<Workspace> workspaces = List<Workspace>.from(
        jsonResponse.map((boardJson) => Workspace.fromJson(boardJson))
      );
      return workspaces;
    } else {
      throw Exception("No workspaces");
    }


  }


  Future<String> getName(id) async {
    String apiToken = (await getApiToken())!;

    final url = Uri.parse('https://api.trello.com/1/organizations/$id/?key=$apiKey&token=$apiToken&field=name');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final name = jsonResponse['displayName'];
      // print(jsonResponse);
      // return jsonResponse;
      return name;
    } else {
      throw Exception("No name");
    }

  }


  Future<Workspace> update(id, displayName) async {
    String apiToken = (await getApiToken())!;

    final url = Uri.parse('https://api.trello.com/1/organizations/$id?key=$apiKey&token=$apiToken&displayName=$displayName');
    final response = await http.put(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Workspace.fromJson(jsonResponse);
    } else {
      throw Exception("Workspace not updated");
    }
  }

  Future<bool> delete(id) async {
    String apiToken = (await getApiToken())!;
    
    final url = Uri.parse('https://api.trello.com/1/organizations/$id?key=$apiKey&token=$apiToken');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Workspace not deleted");
    }
  }

  Future<bool> create(displayName) async {
    String apiToken = (await getApiToken())!;

    final url = Uri.parse('https://api.trello.com/1/organizations?displayName=$displayName&key=$apiKey&token=$apiToken');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Problem creating workspace");
    }
  }
}