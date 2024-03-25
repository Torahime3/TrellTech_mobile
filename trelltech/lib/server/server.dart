import 'dart:io';

import 'package:trelltech/storage/authtoken_storage.dart';

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

      var userToken = request.uri.queryParameters["token"];
      AuthTokenStorage authTokenStorage = AuthTokenStorage();
      authTokenStorage.setAuthToken(userToken!);
      break;
    }
  }
  server.close();
}
