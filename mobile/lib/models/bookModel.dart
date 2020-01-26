class SmallBook {
  String title;
  String cover_image;
  
  SmallBook({this.title,  this.cover_image});

  SmallBook.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        cover_image = json['cover_image'];
}


/* class Book {
  String title;
  List<Author> authors;
  String cover_image;
  int volume_number;
  String publisher;
  int year_published;
  
  Book({this.title, this.authors, this.cover_image, this.publisher, this.year_published});

  Book.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        cover_image = json['cover_image'],
        volume_number = json['volume_number'],
        publisher = json['publisher'],
        year_published = json ['year_published'];
} */

class Author {
  String first_name;
  String last_name;
}

class BookList{
  List<SmallBook> bookList;

  BookList({this.bookList});
}