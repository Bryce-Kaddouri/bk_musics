import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';

import '../models/music_model.dart';
import '../screens/home_screen.dart';
import 'package:flutter/material.dart';

class UploadProvider with ChangeNotifier {
  String? filePath;
  Uint8List? bytes;
  bool isUploading = false;
  bool isDone = false;
  UploadTask? uploadTask;
  String? name;
  List<Music> musicList = [];
  BuildContext? context;
  double uploadProgress = 0;
  bool isRequesting = false;

  void setContext(BuildContext context) {
    this.context = context;
  }

  Future<void> pickFile() async {
    isRequesting = true;
    notifyListeners();
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      if (kIsWeb) {
        bytes = result.files.first.bytes;
      } else {
        filePath = result.files.first.path;
      }
      name = result.files.first.name;

      notifyListeners();
    }

    isRequesting = false;
    notifyListeners();
  }

  Future<TaskSnapshot?> uploadFile(
    String artist,
    String genre,
    String title,
  ) async {
    isUploading = true;
    notifyListeners();

    if (filePath == null && bytes == null) {
      return null; // No file selected, return null
    }

    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}';

    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('musics')
        .child('${formattedDate}.mp3');

    Task task; // Use Task instead of UploadTask

    if (kIsWeb) {
      task = storageRef.putData(
        bytes!,
        SettableMetadata(
          contentType: 'audio/mpeg',
          customMetadata: {
            'artist': artist,
            'genre': genre,
            'title': title,
          },
        ),
      );
    } else {
      final File file = File(filePath!);
      task = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: 'audio/mpeg',
          customMetadata: {
            'artist': artist,
            'genre': genre,
            'title': title,
          },
        ),
      );
    }

    // Listen to snapshotEvents to get progress updates
    task.snapshotEvents.listen(
      (TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;

        // Update the UploadProvider's uploadProgress property
        uploadProgress = progress;
        notifyListeners();
      },
      onError: (Object e) {
        // Handle error if needed
        print(e);
      },
    );

    // Await the completion of the task
    await task.whenComplete(() {
      isUploading = false;
      isDone = true;
      Navigator.of(context!).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    });

    isRequesting = false;
    notifyListeners();

    // Return the Task object for further handling if needed
    return task;
  }

  void reset() {
    filePath = null;
    bytes = null;
    name = null;
    isUploading = false;
    isDone = false;
    notifyListeners();
  }

  Future<void> fetchMusicList() async {
    List<AudioSource> sources = [];

    try {
      final ListResult result =
          await FirebaseStorage.instance.ref().child('musics').list();
      musicList = await Future.wait(result.items.map((item) async {
        final downloadUrl = await item.getDownloadURL();
        FullMetadata metadata = await item.getMetadata();

        return Music(
          name: item.name,
          artist: metadata.customMetadata?['artist'] ?? 'Unknown',
          genre: metadata.customMetadata?['genre'] ?? 'Unknown',
          title: metadata.customMetadata?['title'] ?? 'Unknown',
          downloadUrl: Future.value(downloadUrl),
        );
      }).toList());
      notifyListeners();
    } catch (e) {
      print('Error loading music list: $e');
    }
  }
}
