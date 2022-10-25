import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shorten_url/model/user.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: StreamBuilder<List<History>>(
          stream: readUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<History> users = snapshot.data!;

              return ListView(
                children: [
                  for (int x = 0; x < users.length; x++)
                    users[x].type == "shorten"
                        ? buildShortURL(users[x])
                        : buildGeneratedQR(users[x])
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }

  Widget buildShortURL(History item) => ListTile(
        leading: CircleAvatar(
          child: Text(item.type),
          backgroundColor: Colors.green,
        ),
        title: Text(item.link), //url string
        subtitle: Text(item.date),
      );

  Widget buildGeneratedQR(History item) => ListTile(
        leading: CircleAvatar(child: Text(item.type)),
        title: Text(item.link), //url string
        subtitle: Text(item.date),
      );

  Stream<List<History>> readUsers() => FirebaseFirestore.instance
      .collection('history')
      .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => History.fromJson(doc.data())).toList());
}
