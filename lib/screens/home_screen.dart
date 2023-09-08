import 'package:bk_musics/screens/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/upload_provider.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showWelcomeBackDialog = false;
  @override
  Widget build(BuildContext context) {


    final authProvider = Provider.of<AuthProvider>(context);
    final uploadProvider = Provider.of<UploadProvider>(context);

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
      body: MusicList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => UploadScreen(),),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
class MusicList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uploadProvider = Provider.of<UploadProvider>(context);

    return ListView.builder(
      itemCount: uploadProvider.musicList.length,
      itemBuilder: (context, index) {
        final music = uploadProvider.musicList[index];
        return ListTile(
          title: Text(music.name),
          subtitle: Text('Artist: ${music.artist}, Genre: ${music.genre}'),
          // Add more information or actions for each music file
        );
      },
    );
  }
}
