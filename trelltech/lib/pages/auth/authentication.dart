import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String apiKey = '31b42a669dfa82bfba4203e7b18d6f6e';
const String url =
    'https://trello.com/1/authorize?return_url=http://localhost:8080/authorization&response_type=fragment&scope=read,write&name=TrellTech&callback_method=fragment&key=$apiKey';

class TrelloAuthScreen extends StatelessWidget {
  TrelloAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trello Auth')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
          },
          child: const Text('Authenticate with Trello'),
        ),
      ),
    );
    // flutterWebViewPlugin.onUrlChanged.listen((String url) {
    //   if (url.startsWith(redirectUrl)) {
    //     flutterWebViewPlugin.close();

    //     // Extract token from URL
    //     Uri uri = Uri.parse(url);
    //     String token = uri.queryParameters['token'];

    //     // Save token locally or use it for API requests
    //     print('Trello token: $token');
    //   }
    // });

    // return WebviewScaffold(
    //   url:
    //       'https://trello.com/1/authorize?expiration=1day&name=YourAppName&scope=read,write&response_type=token&key=$apiKey&redirect_uri=$redirectUrl',
    //   appBar: AppBar(title: Text('Trello Auth')),
    // );
  }
}
