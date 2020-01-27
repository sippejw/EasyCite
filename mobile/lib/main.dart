import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mobile/widgets/BookWidget.dart';

import 'models/bookModel.dart';
import 'routes/bookUpload.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyCite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'My Books'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _booksRef = FirebaseDatabase.instance.reference().child('library');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _booksRef.set(null);
              },
            ),
        ]
      ),
      body: StreamBuilder(
        stream: _booksRef.onValue,
        builder: (context, snapshot) {

          if (snapshot.hasData &&
            !snapshot.hasError &&
            snapshot.data.snapshot.value != null) {

            Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
            var library = [];

            if (map != null) {
              map.forEach((i, v) {
                // var bookRef = FirebaseDatabase.instance.reference().child('catalog/' + i);
                
                // bookRef.once().then((DataSnapshot bookSnap) {
                  var book = SmallBook.fromJson(new Map<String, dynamic>.from(v), i);
                  library.add(book);
                // });
              });
            }

            int bookCount = library.length;

            return Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 40.0),
                child: StaggeredGridView.countBuilder(
                  itemCount: bookCount,
                  crossAxisCount: 2,
                  staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
                  mainAxisSpacing: 2.0,
                  crossAxisSpacing: 0.0,
                  itemBuilder: (context, index) {
                    SmallBook book = library[index];

                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: BookWidget(book: book)
                    );
                  }),
              ),
            );
          } else {
            return Center(child: Text("No books yet", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookUpload()),
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


