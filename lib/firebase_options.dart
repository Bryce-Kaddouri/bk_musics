// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAZvs7JK5FHXVn3bmFBJVs-dGhHdh4PH8',
    appId: '1:468155400409:web:ed760b2c3238e5b20e7ec8',
    messagingSenderId: '468155400409',
    projectId: 'bk-musics',
    authDomain: 'bk-musics.firebaseapp.com',
    storageBucket: 'bk-musics.appspot.com',
    measurementId: 'G-L7P85WSFFT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqzbWi3RMZSw6BYdb2FLtU7359AZO9N5I',
    appId: '1:468155400409:android:885bf0c495948fc40e7ec8',
    messagingSenderId: '468155400409',
    projectId: 'bk-musics',
    storageBucket: 'bk-musics.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDnvkhGqxdfpILzBzECg12Gsz95iuD5Fhc',
    appId: '1:468155400409:ios:428535d34b2bab450e7ec8',
    messagingSenderId: '468155400409',
    projectId: 'bk-musics',
    storageBucket: 'bk-musics.appspot.com',
    iosClientId: '468155400409-ii70cmb64bmi07ab7b3ic90fkm50dfik.apps.googleusercontent.com',
    iosBundleId: 'com.example.bkMusics',
  );
}