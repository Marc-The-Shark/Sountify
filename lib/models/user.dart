import 'package:flutter/material.dart';
import 'package:sountify/services/soundcloud_service.dart';
import 'package:sountify/services/spotify_service.dart';

class User extends ChangeNotifier {
  SpotifyService spotifyService = SpotifyService();
  SoundcloudService soundcloudService = SoundcloudService();

}