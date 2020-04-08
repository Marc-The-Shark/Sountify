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
  http.Response response = await spotifyService.authorize();

  HttpServer.bind('0.0.0.0', 8888).then((server) {
    print('Server running at: ${server.address.address}');
    server.transform(HttpBodyHandler()).listen((HttpRequestBody body) async {
      print('not so nice, but ok');
      if(body.request.uri.toString().contains('callback')){
        print('nice');
        body.request.response.write('pups');
        body.request.response.close();
      }
    });
  });

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
    SpotifyService spotifyService = SpotifyService();
    String redirectURI = 'http://localhost:8888/callback/';
    String authorizeUrl =
        'https://accounts.spotify.com/authorize?client_id=${spotifyService.clientID}&response_type=code&'
        'redirect_uri=$redirectURI&scope=streaming%20user-modify-playback-state%20playlist-read-collaborative%20'
        'playlist-read-private%20user-read-currently-playing%20'
        'user-library-read%20user-read-playback-state%20app-remote-control';
    WebViewController _controller;
    return Scaffold(
      appBar: AppBar(title: Text('Help')),
      body: WebView(
        initialUrl: authorizeUrl,
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: <JavascriptChannel>[
          _toasterJavascriptChannel(context),
        ].toSet(),
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
          _controller.loadUrl(authorizeUrl);
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
