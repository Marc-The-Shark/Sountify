import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_server/http_server.dart';
import 'package:sountify/services/spotify_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:sountify/screens/loading_screen.dart';

void main() async {
  await DotEnv().load('.env');
  SpotifyService spotifyService = SpotifyService();

  HttpServer.bind('0.0.0.0', 8888).then((server) {
    print('Server running at: ${server.address.address}');
    server.transform(HttpBodyHandler()).listen((HttpRequestBody body) async {
      body.request.response.headers.set("Content-Type", "application/json");
      body.request.response.headers.add("Access-Control-Allow-Methods", "POST, OPTIONS, GET");
      body.request.response.headers.add("Access-Control-Allow-Origin", "*");
      body.request.response.headers.add('Access-Control-Allow-Headers', '*');
      body.request.response.headers.add('X-Frame-Options', '*');
      print('not so nice, but ok');
      if(body.request.uri.toString().contains('callback')){
        print('nice');
        body.request.response.write('pups');
        body.request.response.close();
      }
    });
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
//      theme: ThemeData.dark(),
      home: SpotifyLogin(),
    );
  }
}

class SpotifyLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SpotifyService spotifyService = SpotifyService();

    WebViewController _controller;
    return Scaffold(
      appBar: AppBar(title: Text('Help')),
      body: WebView(
//        initialUrl: authorizeUrl,
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: <JavascriptChannel>[
          _toasterJavascriptChannel(context),
        ].toSet(),
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
          _controller.loadUrl(spotifyService.authorizeURL);
        },
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          print(message);
        });
  }
}
