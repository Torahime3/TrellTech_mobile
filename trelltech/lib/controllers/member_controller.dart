import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trelltech/models/member_model.dart';
import 'package:trelltech/storage/authtoken_storage.dart';

class MemberController {
  final String? apiKey = dotenv.env['API_KEY'];

  Future<String?> getApiToken() async {
    return await AuthTokenStorage.getAuthToken();
  }

  Future<List<MemberModel>> getMemberDetails({required id}) async {
    String apiToken = (await getApiToken())!;
    final url = Uri.parse(
        "https://api.trello.com/1/members/$id?key=$apiKey&token=$apiToken");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      throw Exception("No member found");
    }
  }
}
