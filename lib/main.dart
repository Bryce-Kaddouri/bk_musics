import 'package:bk_musics/providers/audio_provider.dart';
import 'package:bk_musics/screens/home_screen.dart';
import 'package:bk_musics/utils/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/upload_provider.dart'; // Import the UploadProvider
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioPlayer = AudioPlayer();
  await audioPlayer.setUrl(''); // Initialize with an empty URL

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(audioPlayer: audioPlayer));
}

class MyApp extends StatelessWidget {
  final AudioPlayer audioPlayer;

  MyApp({required this.audioPlayer});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
            create: (context) =>
                UploadProvider()), // Initialize the UploadProvider
        // Add more providers here as needed
        ChangeNotifierProvider(
            create: (context) => AudioProvider(
                  audioPlayer: AudioPlayer(),
                )),
      ],
      child: MaterialApp(
        title: 'My Music App',
        theme: themeData,
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return StreamBuilder<User?>(
      stream: authProvider.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
