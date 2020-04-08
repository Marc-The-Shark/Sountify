import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_server/http_server.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:sountify/services/spotify_service.dart';
import 'package:sountify/screens/loading_screen.dart';

import 'models/user.dart';

final User user = User();

void main() async {
  await DotEnv().load('.env');
  await HttpServer.bind(InternetAddress.loopbackIPv4, 8888).then((server) {
    print('Server running at: ${server.address.address}');
    server.transform(HttpBodyHandler()).listen((HttpRequestBody body) async {
      print(body.request.uri.toString());
      body.request.response.headers.set("Content-Type", "application/json");
      body.request.response.headers
          .add("Access-Control-Allow-Methods", "POST, OPTIONS, GET");
      body.request.response.headers.add("Access-Control-Allow-Origin", "*");
      body.request.response.headers.add('Access-Control-Allow-Headers', '*');
      body.request.response.headers.add('X-Frame-Options', '*');
      if (body.request.uri.toString().contains('callback')) {
        http.Response tokenResponse =
            await http.post('https://accounts.spotify.com/api/token', headers: {
          'Authorization':
              'Basic ${base64.encode(utf8.encode('${SpotifyService.clientID}:${SpotifyService.secretKey}'))}'
        }, body: {
          'grant_type': 'authorization_code',
          'code': body.request.uri.queryParameters['code'],
          'redirect_uri': SpotifyService.redirectURI
        });
        var tokenDict = jsonDecode(tokenResponse.body);
        http.Response playlists = await http.get('${SpotifyService.apiURL}me/playlists', headers: {'Authorization': 'Bearer ${tokenDict['access_token']}'});
        for (var playlist in jsonDecode(playlists.body)){
          print(playlist);
        }
      } else
        body.request.response.write('pinki ponko');
      body.request.response.close();
    });
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<User>(
      create: (context) => user,
      child: MaterialApp(
        title: 'Flutter Demo',
//      theme: ThemeData.dark(),
        home: SpotifyLogin(),
      ),
    );
  }
}

class SpotifyLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SpotifyService spotifyService = SpotifyService();
    String authURL = spotifyService.authorizeURL;
    WebViewController _controller;
    return Scaffold(
      appBar: AppBar(title: Text('Help')),
      body: WebView(
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
