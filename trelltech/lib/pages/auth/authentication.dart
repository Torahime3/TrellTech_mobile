import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trelltech/controllers/member_controller.dart';
import 'package:trelltech/models/member_model.dart';
import 'package:trelltech/pages/home.dart';
import 'package:trelltech/storage/authtoken_storage.dart';
import 'package:url_launcher/url_launcher.dart';

final String? apiKey = dotenv.env['API_KEY'];
final String url =
    'https://trello.com/1/authorize?return_url=http://localhost:8080/authorization&response_type=fragment&scope=read,write&name=TrellTech&callback_method=fragment&key=$apiKey';

class TrelloAuthScreen extends StatefulWidget {
  const TrelloAuthScreen({super.key});

  @override
  State<StatefulWidget> createState() => _TrelloAuthScreenState();
}

class _TrelloAuthScreenState extends State<TrelloAuthScreen> {
  String? fullName;
  String? authToken;
  Function(String?) listener = (String? token) => {};
  final AuthTokenStorage _authTokenStorage = AuthTokenStorage();
  final MemberController _memberController = MemberController();

  _TrelloAuthScreenState() {
    listener = (String? token) {
      setAuthToken(token);
    };
  }

  @override
  void initState() {
    super.initState();
    _authTokenStorage.deleteAuthToken();
    _getInitialInfo();
    AuthTokenStorage.addListener(listener);
  }

  Future<void> _getInitialInfo() async {
    setAuthToken(await _authTokenStorage.getAuthToken());
  }

  void setAuthToken(String? token) async {
    setState(() {
      authToken = token;
      if (token == null) return;
      Future<MemberModel> user =
          _memberController.getMemberDetailsByToken(token: token);
      user.then((value) {
        fullName = value.name;
      });
    });
  }

  @override
  void dispose() {
    AuthTokenStorage.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentification')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("TrellTech",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Text(
                authToken != null
                    ? 'Vous êtes authentifié \n Bienvenue $fullName !'
                    : 'Vous n\'êtes pas authentifié',
                style: const TextStyle(
                  fontSize: 20,
                )),
            const SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: authToken == null
                    ? const Color.fromARGB(255, 56, 166, 255)
                    : Colors.grey,
                minimumSize: const Size(200, 40),
              ),
              onPressed: () async {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.inAppBrowserView);
              },
              child: const Text('Authentification avec Trello'),
            ),
            TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: authToken != null
                        ? const Color.fromARGB(255, 18, 121, 206)
                        : Colors.grey,
                    minimumSize: const Size(200, 40)),
                onPressed: () async {
                  if (authToken != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Vous n'êtes pas authentifié")));
                  }
                },
                child: const Text('Voir mes boards'))
          ],
        ),
      ),
    );
  }
}
