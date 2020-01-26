class Citation {
  String citation_string;
  String page_number;
  
  Citation({this.citation_string, this.page_number});

  Citation.fromJson(Map<String, dynamic> json)
      : citation_string = json['citation_string'],
        page_number = json['page_number'];
}

class CitationList{
  List<Citation> citationList;

  CitationList({this.citationList});
}