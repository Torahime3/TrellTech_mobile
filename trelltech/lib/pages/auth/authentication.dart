import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  String? authToken;
  Function(String?) listener = (String? token) => {};

  _TrelloAuthScreenState() {
    listener = (String? token) {
      setAuthToken(token);
    };
  }

  @override
  void initState() {
    super.initState();
    AuthTokenStorage.deleteAuthToken();
    _getInitialInfo();
    AuthTokenStorage.addListener(listener);
  }

  Future<void> _getInitialInfo() async {
    setAuthToken(await AuthTokenStorage.getAuthToken());
  }

  void setAuthToken(String? token) {
    setState(() {
      authToken = token;
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
      appBar: AppBar(title: const Text('Trello Auth')),
      body: Center(
        child: Column(
          children: [
            Text(authToken != null
                ? 'Vous êtes authentifié'
                : 'Vous n\'êtes pas authentifié'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.inAppBrowserView);
              },
              child: const Text('Authenticate with Trello'),
            ),
            ElevatedButton(
                onPressed: () async {
                  if (authToken != null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
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
