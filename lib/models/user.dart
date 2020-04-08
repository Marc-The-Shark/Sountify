import 'package:flutter/material.dart';
import 'package:sountify/services/soundcloud_service.dart';
import 'package:sountify/services/spotify_service.dart';

class User extends ChangeNotifier {
  SpotifyService _spotifyService = SpotifyService();
  SoundcloudService _soundcloudService = SoundcloudService();

  void setSpotifyTokens(var tokensDict){
    _spotifyService.accessToken = tokensDict['access_token'];
    _spotifyService.refreshToken = tokensDict['refresh_token'];
    notifyListeners();
  }
}