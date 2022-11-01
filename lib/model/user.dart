class History {
  final String docID;
  String originalLink;
  String newLink;
  // String link;
  final String date;
  final String type;
  final String userID;

  History({
    required this.docID,
    this.originalLink = '',
    this.newLink = '',
    // this.link = '',
    required this.date,
    required this.type,
    required this.userID,
  });

  Map<String, dynamic> toJson() => {
        'docID': docID,
        'originalLink': originalLink,
        'newLink': newLink,
        // 'link': link,
        'date': date,
        'type': type,
        'userID': userID,
      };

  static History fromJson(Map<String, dynamic> json) => History(
        docID: json['docID'],
        originalLink: json['originalLink'],
        newLink: json['newLink'],
        // link: json['link'],
        date: json['date'],
        type: json['type'],
        userID: json['userID'],
      );
}

class Feedback {
  String feedback;
  final String date;
  final String type;
  final String userID;

  Feedback({
    this.feedback = '',
    required this.date,
    required this.type,
    required this.userID,
  });

  Map<String, dynamic> toJson() => {
        'feedback': feedback,
        'date': date,
        'type': type,
        'userID': userID,
      };

  static Feedback fromJson(Map<String, dynamic> json) => Feedback(
        feedback: json['feedback'],
        date: json['date'],
        type: json['type'],
        userID: json['userID'],
      );
}
