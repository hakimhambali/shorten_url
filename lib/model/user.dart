class History {
  String originalLink;
  String newLink;
  final String date;
  final String type;
  final String userID;

  History({
    this.originalLink = '',
    this.newLink = '',
    required this.date,
    required this.type,
    required this.userID,
  });

  Map<String, dynamic> toJson() => {
        'originalLink': originalLink,
        'newLink': newLink,
        'date': date,
        'type': type,
        'userID': userID,
      };

  static History fromJson(Map<String, dynamic> json) => History(
        originalLink: json['originalLink'],
        newLink: json['newLink'],
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
