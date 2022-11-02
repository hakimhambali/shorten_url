import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shorten_url/model/user.dart';
import 'package:shorten_url/screens/scan_qr.dart';
import 'package:url_launcher/url_launcher.dart';
import 'register.dart';
import 'view_qr.dart';

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
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: FirebaseAuth.instance.currentUser!.isAnonymous
                            ? const Text(
                                'You have not register yet. Register now to prevent any loss of your history data if you wish to uninstall this app or change devices. You can also login to your account if you have registered before.',
                                textAlign: TextAlign.center)
                            : const Text(
                                'Your history data are bind with your account. Do wish to login to a different account or register a new account ?',
                                textAlign: TextAlign.center),
                        content: SizedBox(
                          height: 80,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 25.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        // icon: const Icon(Icons.close),
                                        child: const Text('Later')),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Register()));
                                        },
                                        // icon: const Icon(Icons.check),
                                        child: const Text('Register Now'))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              })
        ],
      ),
      body: StreamBuilder<List<History>>(
          stream: readUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<History> users = snapshot.data!;

              return ListView(
                children: [
                  for (int x = 0; x < users.length; x++)
                    users[x].type == "Shorten link URL"
                        ? buildShortURL(users[x])
                        : users[x].type == "Generate QR"
                            ? buildGeneratedQR(users[x])
                            : buildScanQR(users[x])
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget buildShortURL(History item) => ListTile(
      title: Text(item.type),
      subtitle: Text(item.date),
      tileColor: Colors.red[200],
      onLongPress: () => showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Are you sure want to delete this ?',
                  textAlign: TextAlign.center),
              content: SizedBox(
                height: 80,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('No')),
                          ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                final deleteUser = FirebaseFirestore.instance
                                    .collection('history')
                                    .doc(item.docID);
                                deleteUser.delete().then((_) => ScaffoldMessenger
                                        .of(context)
                                    .showSnackBar(const SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                            'Successfully delete history'))));
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Yes'))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      onTap: () => showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: SizedBox(
                height: 600,
                child: Column(
                  children: [
                    Column(
                      children: [
                        const Text('Before shorten: '),
                        GestureDetector(
                          onTap: () async {},
                          child: Container(
                            color: Colors.grey.withOpacity(.2),
                            child: Text(item.originalLink),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                      ClipboardData(text: item.originalLink))
                                  .then((_) => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                              'Urls is copied to the clipboard'))));
                            },
                            icon: const Icon(Icons.copy)),
                        IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              var url = Uri.parse(item.originalLink);
                              launchURL(url);
                            }),
                        IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              Share.share(item.originalLink);
                            }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('Copy'),
                        Text('Visit'),
                        Text('Share'),
                      ],
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 20)),
                    Column(
                      children: [
                        const Text('After shorten: '),
                        GestureDetector(
                          onTap: () async {},
                          child: Container(
                            color: Colors.grey.withOpacity(.2),
                            child: Text(item.newLink),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                      ClipboardData(text: item.newLink))
                                  .then((_) => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                              'Urls is copied to the clipboard'))));
                            },
                            icon: const Icon(Icons.copy)),
                        IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              var url = Uri.parse(item.newLink);
                              launchURL(url);
                            }),
                        IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              Share.share(item.newLink);
                            }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('Copy'),
                        Text('Visit'),
                        Text('Share'),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Close'))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }));

  Widget buildGeneratedQR(History item) => ListTile(
        title: Text(item.type),
        subtitle: Text(item.date),
        tileColor: Colors.deepOrange[200],
        onLongPress: () => showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Are you sure want to delete this ?',
                    textAlign: TextAlign.center),
                content: SizedBox(
                  height: 80,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('No')),
                            ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  final deleteUser = FirebaseFirestore.instance
                                      .collection('history')
                                      .doc(item.docID);
                                  deleteUser.delete().then((_) => ScaffoldMessenger
                                          .of(context)
                                      .showSnackBar(const SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                              'Successfully delete history'))));
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Yes'))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ViewQR(item.originalLink, item.newLink))),
        // builder: (context) => ViewQR(item.originalLink, item.newLink))),
      );

  Widget buildScanQR(History item) => ListTile(
        title: Text(item.type),
        subtitle: Text(item.date),
        tileColor: Colors.deepOrange[200],
        onLongPress: () => showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Are you sure want to delete this ?',
                    textAlign: TextAlign.center),
                content: SizedBox(
                  height: 80,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('No')),
                            ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  final deleteUser = FirebaseFirestore.instance
                                      .collection('history')
                                      .doc(item.docID);
                                  deleteUser.delete().then((_) => ScaffoldMessenger
                                          .of(context)
                                      .showSnackBar(const SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                              'Successfully delete history'))));
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Yes'))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                ScanQR(link: item.originalLink))),
      );

  Stream<List<History>> readUsers() => FirebaseFirestore.instance
      .collection('history')
      .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => History.fromJson(doc.data())).toList());

  Future<bool> launchURL(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      print("launched URL: $url");
      return true;
    } else {
      print('Could not launch $url');
      return false;
    }
  }
}
