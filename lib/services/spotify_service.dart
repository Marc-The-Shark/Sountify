import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:sountify/services/common.dart';

class SpotifyService extends Service {
  static const String url = 'https://api.spotify.com/v1/';
  final String clientID = DotEnv().env['SPOTIFY_CLIENT_ID'];
  final String secretKey = DotEnv().env['SPOTIFY_CLIENT_SECRET'];

  Future<http.Response> authorize() async {
    return await http.get(
        'https://accounts.spotify.com/authorize?client_id=$clientID&response_type=code&'
            'redirect_uri=localhost:8080/&&scope=streaming%20user-modify-playback-state%20playlist-read-collaborative%20'
            'playlist-read-private%20user-read-currently-playing%20'
            'user-library-read%20user-read-playback-state%20app-remote-control');
  }
}
