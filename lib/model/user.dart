import 'package:cloud_firestore/cloud_firestore.dart';

class History {
  String link;
  final String date;
  final String type;
  final String userID;

  History({
    this.link = '',
    required this.date,
    required this.type,
    required this.userID,
  });

  Map<String, dynamic> toJson() => {
        'link': link,
        'date': date,
        'type': type,
        'userID': userID,
      };

  static History fromJson(Map<String, dynamic> json) => History(
        link: json['link'],
        date: json['date'],
        type: json['type'],
        userID: json['userID'],
      );
}
