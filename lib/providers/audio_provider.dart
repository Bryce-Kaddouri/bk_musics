import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum AudioPlayerState { stopped, playing, paused }

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer;
  AudioPlayerState audioPlayerState = AudioPlayerState.stopped;
  Duration? duration;
  Duration? position;
  int? currentIndex;
  bool isOnTap = true;

  AudioProvider({required AudioPlayer audioPlayer})
      : _audioPlayer = audioPlayer;

  Future<void> playMusicFromUrl(String url, int? index) async {
    audioPlayerState = AudioPlayerState.playing;
    currentIndex = index;
    position = Duration.zero;
    isOnTap = true;
    notifyListeners();
    try {
      //stop the previous music
      if (audioPlayerState == AudioPlayerState.playing) {
        await _audioPlayer.stop();
      }
      Duration? duration = await _audioPlayer.setUrl(url);
      if (duration != null) {
        this.duration = duration;
      }
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio from URL: $e');
    }
  }

  Future<void> pauseMusic() async {
    audioPlayerState = AudioPlayerState.paused;
    notifyListeners();
    await _audioPlayer.pause();
  }

  Future<void> stopMusic() async {
    audioPlayerState = AudioPlayerState.stopped;
    notifyListeners();
    await _audioPlayer.stop();
  }

  Future<void> resumeMusic() async {
    audioPlayerState = AudioPlayerState.playing;
    notifyListeners();
    await _audioPlayer.play();
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

  //stream the position and duration of the audio
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<Duration?> get positionStream => _audioPlayer.positionStream;
}
