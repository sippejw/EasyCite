import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/models/bookModel.dart';
import 'package:path/path.dart';

class CitationUpload extends StatefulWidget {
  CitationUpload({
    Key key,
    @required this.book,
  }) : super(key: key);

  final SmallBook book;

  @override
  _CitationUploadState createState() => _CitationUploadState();
}

class _CitationUploadState extends State<CitationUpload> {
  File _image;
  String _uploadedFilePath;
  final pageNumController = TextEditingController();

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

  Future addCitation(String isbn, String page_number) async {

    FirebaseDatabase.instance.reference().child('uploads').push().set({
      'image': _uploadedFilePath,
      'type': 'quote',
      "isbn": isbn,
      "page_number": page_number
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    pageNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new citation"),
      ),
      body: Center(
        child: SingleChildScrollView (
          child: _image == null
            ? RaisedButton(
              onPressed: takePhoto,
              child: Text('Take photo!'),
            )
            : Column(children: <Widget>[
                Image(image: FileImage(_image)),
                _uploadedFilePath == null ?
                  CircularProgressIndicator() :
                  Column(
                    children: <Widget>[
                      TextField(
                        controller: pageNumController,
                        decoration: InputDecoration(
                          hintText: 'Enter page number'
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          addCitation(widget.book.isbn, pageNumController.text);
                          Navigator.pop(context);
                        },
                        child: Text('Add citation')
                      ),
                    ],
                  )
              ]),
        ),
      ),
    );
  }
}
