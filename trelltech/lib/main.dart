import 'package:flutter/material.dart';
import 'package:trelltech/pages/auth/authentication.dart';
import 'package:trelltech/server/server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  startWebServer();
  dotenv.load();
  runApp(const TrellTech());
}

class TrellTech extends StatelessWidget {
  const TrellTech({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: TrelloAuthScreen());
  }
}
