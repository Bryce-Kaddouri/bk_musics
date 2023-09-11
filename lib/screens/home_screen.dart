import 'package:bk_musics/screens/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../models/music_model.dart';
import '../providers/audio_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/upload_provider.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showWelcomeBackDialog = false;
  List<AudioSource> sources = [];
  Music? currentMusic;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final uploadProvider = Provider.of<UploadProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);

    uploadProvider.fetchMusicList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: uploadProvider.musicList.length == 0
              ? 1
              : uploadProvider.musicList.length,
          itemBuilder: (context, index) {
            if (uploadProvider.musicList.isEmpty) {
              return ListTile(
                title:
                    Text('No music files found', textAlign: TextAlign.center),
              );
            }
            final music = uploadProvider.musicList[index];
            return ListTile(
              title: Text(
                music.title,
                textAlign: TextAlign.center,
              ),
              leading: Icon(Icons.music_note, size: 30.0),
              dense: true,
              visualDensity: VisualDensity.compact,
              isThreeLine: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: audioProvider.currentIndex == index &&
                        (audioProvider.audioPlayerState ==
                                AudioPlayerState.playing ||
                            audioProvider.audioPlayerState ==
                                AudioPlayerState.paused)
                    ? BorderSide(color: Colors.blue, width: 2.0)
                    : BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(8.0),
              subtitle: Text(
                'Artist: ${music.artist}, Genre: ${music.genre}',
                textAlign: TextAlign.center,
              ),
              onTap: () async {
                String url = await music.downloadUrl;
                audioProvider.playMusicFromUrl(url, index);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UploadScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      persistentFooterButtons: [
        Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                audioProvider.audioPlayerState == AudioPlayerState.paused ||
                        audioProvider.audioPlayerState ==
                            AudioPlayerState.playing
                    ? StreamBuilder(
                        stream: audioProvider.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data as Duration?;
                          return StreamBuilder(
                            stream: audioProvider.durationStream,
                            builder: (context, snapshot) {
                              final duration = snapshot.data as Duration?;
                              if (position != null &&
                                  duration != null &&
                                  position!.inSeconds == duration!.inSeconds) {
                                audioProvider.isOnTap = false;

                                int size = uploadProvider.musicList.length;
                                if (audioProvider.currentIndex == size - 1 &&
                                    audioProvider.isOnTap == false) {
                                  uploadProvider.musicList[0].downloadUrl.then(
                                    (value) => audioProvider.playMusicFromUrl(
                                        value, 0),
                                  );
                                } else if (audioProvider.isOnTap == false) {
                                  uploadProvider
                                      .musicList[
                                          audioProvider.currentIndex! + 1]
                                      .downloadUrl
                                      .then(
                                    (value) => audioProvider.playMusicFromUrl(
                                        value, audioProvider.currentIndex! + 1),
                                  );
                                }
                              }
                              return Slider(
                                min: 0.0,
                                max: duration?.inSeconds.toDouble() ?? 0.0,
                                value: position?.inSeconds.toDouble() ?? 0.0,
                                onChanged: (value) {
                                  audioProvider.seekToSecond(value.toInt());
                                },
                              );
                            },
                          );
                        },
                      )
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    if ((audioProvider.audioPlayerState ==
                                AudioPlayerState.playing ||
                            audioProvider.audioPlayerState ==
                                AudioPlayerState.paused) &&
                        (audioProvider.currentIndex != null))
                      Text(
                        '${uploadProvider.musicList[audioProvider.currentIndex!].title}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: () async {
                        if (audioProvider.currentIndex == 0) return;
                        String url = await uploadProvider
                            .musicList[audioProvider.currentIndex! - 1]
                            .downloadUrl;

                        audioProvider.playMusicFromUrl(
                            url, audioProvider.currentIndex! - 1);
                      },
                    ),
                    if (audioProvider.audioPlayerState ==
                        AudioPlayerState.playing)
                      IconButton(
                        icon: Icon(Icons.pause),
                        onPressed: () {
                          audioProvider.pauseMusic();
                        },
                      )
                    else if (audioProvider.audioPlayerState ==
                            AudioPlayerState.paused ||
                        audioProvider.audioPlayerState ==
                            AudioPlayerState.stopped)
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () async {
                          if (audioProvider.currentIndex == null) {
                            String url =
                                await uploadProvider.musicList[0].downloadUrl;
                            audioProvider.playMusicFromUrl(url, 0);
                          } else {
                            audioProvider.resumeMusic();
                          }
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: () async {
                        if (audioProvider.currentIndex ==
                            uploadProvider.musicList.length - 1) return;
                        String url = await uploadProvider
                            .musicList[audioProvider.currentIndex! + 1]
                            .downloadUrl;

                        audioProvider.playMusicFromUrl(
                            url, audioProvider.currentIndex! + 1);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () {
                        audioProvider.stopMusic();
                      },
                    ),
                  ],
                ),
              ],
            )),
      ],
    );
  }
}
