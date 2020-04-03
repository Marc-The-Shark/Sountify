import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sountify/services/spotify_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:sountify/screens/loading_screen.dart';

void main() async {
  DotEnv().load('.env');
  SpotifyService spotifyService = SpotifyService();
  http.Response response = await spotifyService.authorize();
  runApp(MyApp(response.body));
}

class MyApp extends StatelessWidget {
  MyApp(this.loginHTML);

  final String loginHTML;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
//      theme: ThemeData.dark(),
      home: SpotifyLogin(loginHTML),
    );
  }
}

class SpotifyLogin extends StatelessWidget {
  SpotifyLogin(this.loginHTML);

  final String loginHTML;

  @override
  Widget build(BuildContext context) {
    WebViewController _controller;
    return Scaffold(
      appBar: AppBar(title: Text('Help')),
      body: WebView(
        initialUrl: 'about:blank',
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: <JavascriptChannel>[
          _toasterJavascriptChannel(context),
        ].toSet(),
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
          _controller.loadUrl(Uri.dataFromString(loginHTML,
                  mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
              .toString());
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
