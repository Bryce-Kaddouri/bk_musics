import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum AudioPlayerState { stopped, playing, paused }

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer;
  AudioPlayerState audioPlayerState = AudioPlayerState.stopped;
  Duration? duration;
  Duration? position;
  int currentIndex = 0;

  AudioProvider({required AudioPlayer audioPlayer})
      : _audioPlayer = audioPlayer;

  Future<void> playMusicFromUrl(String url, int index) async {
    print('Playing music from URL: $url');
    print('Index: $index');
    try {
      //stop the previous music
      if (audioPlayerState == AudioPlayerState.playing) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      audioPlayerState = AudioPlayerState.playing;
      currentIndex = index;
    } catch (e) {
      print('Error playing audio from URL: $e');
    }
    notifyListeners();
  }

  Future<void> pauseMusic() async {
    await _audioPlayer.pause();
    audioPlayerState = AudioPlayerState.paused;
    notifyListeners();
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    audioPlayerState = AudioPlayerState.stopped;
    notifyListeners();
  }

  Future<void> resumeMusic() async {
    await _audioPlayer.play();
    audioPlayerState = AudioPlayerState.playing;
    notifyListeners();
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    _audioPlayer.seek(newDuration);
  }

  void setDuration(Duration duration) {
    this.duration = duration;
    notifyListeners();
  }

  void setPosition(Duration position) {
    this.position = position;
    notifyListeners();
  }

  void setAudioPlayerState(AudioPlayerState audioPlayerState) {
    this.audioPlayerState = audioPlayerState;
    notifyListeners();
  }

  void reset() {
    audioPlayerState = AudioPlayerState.stopped;
    duration = null;
    position = null;
    notifyListeners();
  }
}
