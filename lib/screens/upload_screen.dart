import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/upload_provider.dart';

class UploadScreen extends StatelessWidget {
  // global key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // text editing controllers for artist and genre and title
  final TextEditingController artistController = TextEditingController();

  final TextEditingController genreController = TextEditingController();

  final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final uploadProvider = Provider.of<UploadProvider>(context);
    uploadProvider.setContext(context); // Set the context

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload MP3'),
        automaticallyImplyLeading: false,
        leading: uploadProvider.isUploading
            ? Container()
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
      ),
      body: SingleChildScrollView(
        child: !uploadProvider.isUploading
            ? Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // step 1 - pickFile
                    Text('Step 1: Pick an MP3 file',
                        style: TextStyle(fontSize: 20.0)),
                    SizedBox(height: 20.0),
                    if (uploadProvider.name == null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          elevation: 5.0,
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.8, 50.0),
                        ),
                        onPressed: () {
                          uploadProvider.pickFile();
                        },
/*
                        icon: Icon(Icons.music_note),
*/
                        /*label: Text('Pick an MP3 File'),*/
                        child: uploadProvider.isRequesting
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.music_note),
                                  SizedBox(width: 10.0),
                                  Text('Pick an MP3 File'),
                                ],
                              ),
                      ),
                    if (uploadProvider.name != null)
                      ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        leading: Icon(Icons.music_note),
                        title: Text(uploadProvider.name ?? ''),
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            uploadProvider.reset();
                          },
                        ),
                      ),
                    SizedBox(height: 20.0),
                    // step 2 - enter artist and genre and title
                    if (uploadProvider.name != null)
                      Container(
                        child: Column(
                          children: [
                            Text('Step 2: Enter Artist and Genre and Title',
                                style: TextStyle(fontSize: 20.0)),
                            SizedBox(height: 20.0),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: artistController,
                                    decoration:
                                        InputDecoration(labelText: 'Artist'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the artist.';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20.0),
                                  TextFormField(
                                    controller: genreController,
                                    decoration:
                                        InputDecoration(labelText: 'Genre'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the genre.';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20.0),
                                  TextFormField(
                                    controller: titleController,
                                    decoration:
                                        InputDecoration(labelText: 'Title'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the title.';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20.0),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      elevation: 5.0,
                                      fixedSize: Size(
                                          MediaQuery.of(context).size.width *
                                              0.8,
                                          50.0),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        print(
                                            'uploadProvider.uploadFile: ${uploadProvider.bytes}');
                                        var task =
                                            await uploadProvider.uploadFile(
                                          artistController.text,
                                          genreController.text,
                                          titleController.text,
                                        );
                                      }
                                    },
                                    child: uploadProvider.isRequesting
                                        ? CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.cloud_upload),
                                              SizedBox(width: 10.0),
                                              Text('Upload MP3 File'),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              )
            : Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Uploading of ${uploadProvider.name} in progress...',
                        style: TextStyle(fontSize: 20.0)),
                    SizedBox(height: 20.0),
                    LinearProgressIndicator(
                        value: uploadProvider.uploadProgress),
                    SizedBox(height: 20.0),
                    Icon(
                      Icons.cloud_upload,
                      size: 100.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
