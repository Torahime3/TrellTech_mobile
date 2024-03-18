import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:trelltech/storage/authtoken_storage.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> startWebServer() async {
  // BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);

  await for (var request in server) {
    // GET /authorization
    if (request.uri.toString().startsWith("/authorization")) {
      request.response
        ..headers.contentType = ContentType("text", "html", charset: "utf-8")
        ..write(
            "<script> window.location.replace('http://localhost:8080/getAccessToken?token=' + window.location.hash.split('token=')[1]) </script>")
        ..close();

      // GET /getAccessToken
    } else if (request.uri.toString().startsWith("/getAccessToken")) {
      request.response
        ..headers.contentType = ContentType("text", "html", charset: "utf-8")
        ..write(
            "<h1 style={font-size: 50px;}>Authentification réussie, merci de quitter cette page</h1>")
        ..close();

      // print(request.uri.queryParameters["token"]);
      var userToken = request.uri.queryParameters["token"];
      AuthTokenStorage.setAuthToken(userToken!);
      break;
    }
  }
  server.close();
}
