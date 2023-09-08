import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/music_model.dart';
import '../screens/home_screen.dart';

class UploadProvider with ChangeNotifier {
  String? filePath;
  Uint8List? bytes;
  bool isUploading = false;
  bool isDone = false;
  double uploadProgress = 0.0; // Track upload progress
  UploadTask? uploadTask; // Store the UploadTask
  String? name;
  List<Music> musicList = []; // Store music items as instances of Music model
  BuildContext? context; // Store the context

  // method to set the context
  void setContext(BuildContext context) {
    this.context = context;
  }


  Future<void> pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['mp3'],

    );

    if (result != null) {
     /* filePath = result.files.first.path;
      Uint8List fileBytes = result.files.first.bytes!;*/
      if(kIsWeb){
        bytes = result.files.first.bytes;
      }else{
        filePath = result.files.first.path;
      }
      name = result.files.first.name;



      notifyListeners();
    }
  }

  // Add a method to pause the upload
  void pauseUpload() {
    if (uploadTask != null) {
      uploadTask!.pause();
      isUploading = false;
      notifyListeners();
    }
  }

  // Add a method to resume the upload
  void resumeUpload() {
    if (uploadTask != null) {
      uploadTask!.resume();
      isUploading = true;
      notifyListeners();
    }
  }

  // Add a method to cancel the upload
  void cancelUpload() {
    if (uploadTask != null) {
      uploadTask!.cancel();
      isUploading = false;
      uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<void> uploadFile(String artist, String genre, String title) async {
    if (filePath == null) {
      return; // No file selected, do nothing
    }

    isUploading = true;
    notifyListeners();
/*
    UploadTask uploadTask;
*/

    DateTime now = DateTime.now();
    String formattedDate = '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}';

    final Reference storageRef = FirebaseStorage.instance.ref().child('musics').child('${formattedDate}.mp3');
    // check if the file is already uploaded
    print('storageRef: $storageRef');


    if(kIsWeb){
      uploadTask =  storageRef.putData(bytes!,
        // You can customize the metadata if needed.
        SettableMetadata(contentType: 'audio/mpeg', customMetadata: {
          'artist': artist,
          'genre': genre,
          'title': title,
        }), );
    }else{
      final File file = File(filePath!);
      uploadTask = storageRef.putFile(
        file,
        // You can customize the metadata if needed.
        SettableMetadata(contentType: 'audio/mpeg', customMetadata: {
          'artist': artist,
          'genre': genre,
          'title': title,
        }),
      );
    }


    // Monitor the upload progress
    uploadTask?.snapshotEvents.listen((TaskSnapshot snapshot) {
      uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
      print('Upload progress: $uploadProgress');
      notifyListeners();
    }, onError: (Object e) {
      // In case something goes wrong
      print(e); // TODO: Remove this when you're done debugging
      reset();
      notifyListeners();
    }, 
    onDone: () {
      // When the task is done, update the database
      isUploading = false;
      isDone = true;

      /*notifyListeners();
      await fetchMusicList();*/
      Navigator.of(context!).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen(),),
      );
    });
    

  }

  void reset() {
    filePath = null;
    bytes = null;
    name = null;
    isUploading = false;
    uploadProgress = 0.0;
    notifyListeners();
  }


  Future<void> fetchMusicList() async {
    try {
      final ListResult result = await FirebaseStorage.instance.ref().child('musics').list();
      musicList = await Future.wait(result.items.map((item) async {
        // Parse metadata or customize this part based on your data structure
        final downloadUrl = await item.getDownloadURL();
        FullMetadata metadata = await item.getMetadata();

        return Music(
          name: item.name,
          artist: metadata.customMetadata?['artist'] ?? 'Unknown',
          genre: metadata.customMetadata?['genre'] ?? 'Unknown',
          title: metadata.customMetadata?['title'] ?? 'Unknown',
          downloadUrl: Future.value(downloadUrl), // Convert to Future<String>
        );
      }).toList());
      notifyListeners();
    } catch (e) {
      print('Error loading music list: $e');
    }
  }






}
