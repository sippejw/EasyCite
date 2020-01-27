import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/models/bookModel.dart';
import 'package:mobile/models/citation.dart';
import 'package:path/path.dart';

class BookDetail extends StatefulWidget {
  BookDetail({
    Key key,
    @required this.book,
  }) : super(key: key);

  final SmallBook book;

  @override
  _BookDetailState createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
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
    
    final _citationsRef = FirebaseDatabase.instance.reference().child('library/' + widget.book.isbn + '/citations' );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
      ),
      body: 
       SingleChildScrollView(
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _image == null ?
            <Widget>[
              AspectRatio(
                aspectRatio: 4/3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: FutureBuilder<dynamic>(
                    future: _getImageUrl(widget.book.cover_image),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        return AspectRatio(
                          aspectRatio: 4/3,
                          child: Image.network(snapshot.data,
                            fit: BoxFit.contain
                          )
                        );
                      }
                    }
                  ),
                )
              ),
              /* Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Citations within this text:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ), */
              StreamBuilder(
                stream: _citationsRef.onValue,
                builder: (context, snapshot) {

                  if (snapshot.hasData &&
                    !snapshot.hasError &&
                    snapshot.data.snapshot.value != null) {

                    print(snapshot);

                    List<dynamic> map = snapshot.data.snapshot.value;
                    var citations = [];

                    if (map != null) {
                      map.forEach((v) {
                        var citation = Citation.fromJson(new Map<String, dynamic>.from(v));
                        citations.add(citation);
                        print(citation);
                      });
                    }

                    print(citations);

                    int citationCount = citations.length;

                    return Container(
                      child: ListView.builder(
                        itemCount: citationCount,
                        itemBuilder: (context, index) {
                          
                          return Text('test');
                        }),
                    );
                  } else {
                    return Text("No data");
                  }
                },
              ),
            ] :
            <Widget>[
              Column(children: <Widget>[
                AspectRatio(
                  aspectRatio: 4/3,
                  child: Image(image: FileImage(_image),
                    fit: BoxFit.contain
                  )
                ),
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
                ]
              ),
            ]
        ),
       ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          takePhoto();
        },
        tooltip: 'Increment',
        child: Icon(Icons.edit),
      ), // This tra,
    );
  }
}

Future<dynamic> _getImageUrl(String path) async {
  final Future<StorageReference> ref =
      FirebaseStorage.instance.getReferenceFromUrl(path);
  return await ref.then((doc) => doc.getDownloadURL());
}