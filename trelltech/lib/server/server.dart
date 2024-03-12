import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void webServer() async {
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print("Server running on IP : " +
      server.address.toString() +
      " On Port : " +
      server.port.toString());
  await for (var request in server) {
    print(request);
    if (request.uri.toString().startsWith("/authorization")) {
      request.response
        ..headers.contentType = ContentType("text", "html", charset: "utf-8")
        ..write(
            "<script> window.location.replace('http://localhost:8080/getAccessToken?token=' + window.location.hash.split('token=')[1]) </script>")
        ..close();
    } else if (request.uri.toString().startsWith("/getAccessToken")) {
      print(request.uri.queryParameters["token"]);
      request.response
        ..headers.contentType = ContentType("text", "html", charset: "utf-8")
        ..write(
            "<h1 style={font-size: 50px;}>Redirection vers l'application... si vous n'êtes pas rediriger dans les 5 secondes, faites le vous mêmes</h1>")
        ..close();
      break;
    }
  }
  server.close();
  print("Serveur web arrêté");
}
