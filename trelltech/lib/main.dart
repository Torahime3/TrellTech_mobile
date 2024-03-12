import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:mini_server/mini_server.dart';
import 'package:trelltech/pages/auth/authentication.dart';
import 'package:trelltech/server/server.dart';

import 'pages/home.dart';

void main() {
  Isolate.run(() => webServer());
  runApp(const TrellTech());
}

class TrellTech extends StatelessWidget {
  const TrellTech({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: TrelloAuthScreen());
  }
}
