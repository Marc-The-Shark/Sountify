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
        var tokensDict = jsonDecode(tokenResponse.body);
        user.setSpotifyTokens(tokensDict);
        http.Response playlists = await http.get('${SpotifyService.apiURL}me/playlists', headers: {'Authorization': 'Bearer ${tokensDict['access_token']}'});
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
    WebViewController _controller;
    return Scaffold(
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
          _controller.loadUrl(SpotifyService.authorizeURL);
        },
      ),
    );
  }
}
