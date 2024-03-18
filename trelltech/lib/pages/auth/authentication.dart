import 'package:flutter/material.dart';
import 'package:trelltech/pages/home.dart';
import 'package:trelltech/storage/authtoken_storage.dart';
import 'package:url_launcher/url_launcher.dart';

const String apiKey = '31b42a669dfa82bfba4203e7b18d6f6e';
const String url =
    'https://trello.com/1/authorize?return_url=http://localhost:8080/authorization&response_type=fragment&scope=read,write&name=TrellTech&callback_method=fragment&key=$apiKey';

class TrelloAuthScreen extends StatelessWidget {
  const TrelloAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trello Auth')),
      body: Center(
        child: Column(
          children: [
            Text(AuthTokenStorage.getAuthToken() != ""
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
                  if (await AuthTokenStorage.getAuthToken() != null) {
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
