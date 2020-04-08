import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sountify/services/common.dart';

class SpotifyService extends Service {
  static const String apiURL = 'https://api.spotify.com/v1/';
  static final String clientID = DotEnv().env['SPOTIFY_CLIENT_ID'];
  static final String secretKey = DotEnv().env['SPOTIFY_CLIENT_SECRET'];
  static const redirectURI = 'http://localhost:8888/callback/';

  String get authorizeURL {
    return 'https://accounts.spotify.com/authorize?client_id=$clientID&response_type=code&'
        'redirect_uri=$redirectURI&scope=streaming%20user-modify-playback-state%20playlist-read-collaborative%20'
        'playlist-read-private%20user-read-currently-playing%20'
        'user-library-read%20user-read-playback-state%20app-remote-control';
  }
}
