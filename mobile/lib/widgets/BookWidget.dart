

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/bookModel.dart';
import 'package:mobile/routes/citationUpload.dart';

class BookWidget extends StatelessWidget {
  
  BookWidget({
    Key key,
    @required this.book
  }) : super(key: key);

  final SmallBook book;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CitationUpload(book: book)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(
                color: Color.fromARGB(100, 0, 0, 0),
                offset: Offset(0.0, 3.0),
                blurRadius: 4.0
              )]
            ),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: FutureBuilder<dynamic>(
                  future: _getImageUrl(book.cover_image),
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return Image.network(snapshot.data,
                        fit: BoxFit.cover
                      );
                    }
                  }
                ),
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              book.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0
              )
            ),
          )
        ],
      )
    );
  }
}

Future<dynamic> _getImageUrl(String path) async {
  final Future<StorageReference> ref =
      FirebaseStorage.instance.getReferenceFromUrl(path);
  return await ref.then((doc) => doc.getDownloadURL());
}