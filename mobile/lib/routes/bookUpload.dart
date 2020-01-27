import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class BookUpload extends StatefulWidget {
  @override
  _BookUploadState createState() => _BookUploadState();
}

class _BookUploadState extends State<BookUpload> {
  File _image;
  String _uploadedFilePath;

  Future takePhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });

    uploadFile();
  }

  Future uploadFile() async {
    StorageReference storageReference = FirebaseStorage.instance
      .ref()
      .child('books/${basename(_image.path)}');

    StorageUploadTask uploadTask = storageReference.putFile(_image);

    await uploadTask.onComplete;

    var bucket = await storageReference.getBucket();
    var path = await storageReference.getPath();
    var fullPath = "gs://" + bucket + path;

    setState(() {
      _uploadedFilePath = fullPath;
    });
  }

  Future addBook() async {
    FirebaseDatabase.instance.reference().child('uploads').push().set({
      'image': _uploadedFilePath,
      'type': 'cover'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new book"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            _image == null
                ? RaisedButton(
                  onPressed: takePhoto,
                  child: Text('Take photo'),
                )
                : Column(children: <Widget>[
                    Image(image: FileImage(_image)),
                    _uploadedFilePath == null ?
                      CircularProgressIndicator() :
                      RaisedButton(onPressed: () {
                        addBook();
                        Navigator.pop(context);
                      }, child: Text('Add book'))
                  ])
          ],
        ),
      ),
    );
  }
}
