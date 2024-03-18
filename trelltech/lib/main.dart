import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trelltech/pages/auth/authentication.dart';
import 'package:trelltech/server/server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trelltech/storage/authtoken_storage.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
  // Isolate.spawn(startWebServer, rootIsolateToken);
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
