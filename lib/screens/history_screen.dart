import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shorten_url/model/user.dart';
import 'package:shorten_url/screens/result_scan_qr.dart';
import 'package:url_launcher/url_launcher.dart';
import 'register.dart';
import 'result_generate_qr.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool reverseSort = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('History'),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              setState(() {
                reverseSort = !reverseSort;
              });
            },
          ),
          FirebaseAuth.instance.currentUser!.isAnonymous
              ? IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () {
                    return PanaraConfirmDialog.show(
                      context,
                      title: "Register Now ?",
                      message:
                          'You have not register yet. Register now to prevent any loss of your history data if you wish to uninstall this app or change devices. You can also login to your account if you have registered before.',
                      confirmButtonText: "Yes",
                      cancelButtonText: "No",
                      onTapCancel: () {
                        Navigator.pop(context);
                      },
                      onTapConfirm: () {
                        if (!FirebaseAuth.instance.currentUser!.isAnonymous) {
                          FirebaseAuth.instance.signOut();
                          FirebaseAuth.instance.signInAnonymously();
                        }
                        Navigator.pop(context);
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Register()))
                            .then((value) {
                          setState(() {});
                        });
                      },
                      panaraDialogType: PanaraDialogType.normal,
                      barrierDismissible: false,
                    );
                  })
              : IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () {
                    return PanaraConfirmDialog.show(
                      context,
                      title: "Logout Now ?",
                      message:
                          'Your history data are bind with your account. You have to logout in order to login to a different account or register a new account',
                      confirmButtonText: "Yes",
                      cancelButtonText: "No",
                      onTapCancel: () {
                        Navigator.pop(context);
                      },
                      onTapConfirm: () {
                        if (!FirebaseAuth.instance.currentUser!.isAnonymous) {
                          FirebaseAuth.instance.signOut();
                          FirebaseAuth.instance.signInAnonymously();
                        }
                        Navigator.pop(context);
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Register()))
                            .then((value) {
                          setState(() {});
                        });
                      },
                      panaraDialogType: PanaraDialogType.normal,
                      barrierDismissible: false,
                    );
                  })
        ],
      ),
      body: StreamBuilder<List<History>>(
          stream: readUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<History> users = snapshot.data!;
              users.sort((a, b) {
                DateTime adate = DateTime.parse(a.date.toString());
                DateTime bdate = DateTime.parse(b.date.toString());
                return reverseSort
                    ? -bdate.compareTo(adate)
                    : -adate.compareTo(bdate);
              });
              return ListView(
                children: [
                  for (int x = 0; x < users.length; x++)
                    users[x].type == "Shorten URL"
                        ? buildShortURL(users[x])
                        : users[x].type == "Generate QR"
                            ? buildGeneratedQR(users[x])
                            : users[x].type == "Scan QR"
                                ? buildScanQR(users[x])
                                : buildScanDocument(users[x])
                ],
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You may not have any history data yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17),
                  ),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }
          }),
    );
  }

  Widget buildShortURL(History item) => Padding(
        padding: EdgeInsets.only(top: 8, left: 8, right: 8),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.red[100], borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text(item.type),
              subtitle: Text(DateFormat('dd/MM/yyyy')
                  .add_jm()
                  .format(DateTime.parse(item.date))
                  .toString()),
              onLongPress: () => PanaraConfirmDialog.show(
                context,
                title: "Delete this ?",
                message: 'Are you sure want to delete this ?',
                confirmButtonText: "Yes",
                cancelButtonText: "No",
                onTapCancel: () {
                  Navigator.pop(context);
                },
                onTapConfirm: () {
                  Navigator.pop(context);
                  final deleteUser = FirebaseFirestore.instance
                      .collection('history')
                      .doc(item.docID);
                  deleteUser.delete().then((_) => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Successfully delete history data'))));
                },
                panaraDialogType: PanaraDialogType.error,
                barrierDismissible: false,
              ),
              onTap: () => AwesomeDialog(
                context: context,
                animType: AnimType.scale,
                dialogType: DialogType.noHeader,
                body: SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          const Text('Before shorten: ',
                              style: TextStyle(fontSize: 16)),
                          GestureDetector(
                            onTap: () async {},
                            child: Container(
                              color: Colors.grey.withOpacity(.2),
                              child: Text(
                                item.originalLink,
                                style: TextStyle(fontSize: 16),
                              ),
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
                          const Text('After shorten: ',
                              style: TextStyle(fontSize: 16)),
                          GestureDetector(
                            onTap: () async {},
                            child: Container(
                              color: Colors.grey.withOpacity(.2),
                              child: Text(
                                item.newLink,
                                style: TextStyle(fontSize: 16),
                              ),
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
                    ],
                  ),
                ),
                title: 'This is Ignored',
                desc: 'This is also Ignored',
                btnOkOnPress: () {},
              )..show(),
            ),
          ),
        ),
      );

  Widget buildGeneratedQR(History item) => Padding(
        padding: EdgeInsets.only(top: 8, left: 8, right: 8),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text(item.type),
              subtitle: Text(DateFormat('dd/MM/yyyy')
                  .add_jm()
                  .format(DateTime.parse(item.date))
                  .toString()),
              onLongPress: () => PanaraConfirmDialog.show(
                context,
                title: "Delete this ?",
                message: 'Are you sure want to delete this ?',
                confirmButtonText: "Yes",
                cancelButtonText: "No",
                onTapCancel: () {
                  Navigator.pop(context);
                },
                onTapConfirm: () {
                  Navigator.pop(context);
                  final deleteUser = FirebaseFirestore.instance
                      .collection('history')
                      .doc(item.docID);
                  deleteUser.delete().then((_) => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Successfully delete history data'))));
                },
                panaraDialogType: PanaraDialogType.error,
                barrierDismissible: false,
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ViewQR(
                        originalLink: item.originalLink,
                        newLink: item.originalLink,
                      ))),
            ),
          ),
        ),
      );

  Widget buildScanQR(History item) => Padding(
        padding: EdgeInsets.only(top: 8, left: 8, right: 8),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text(item.type),
              subtitle: Text(DateFormat('dd/MM/yyyy')
                  .add_jm()
                  .format(DateTime.parse(item.date))
                  .toString()),
              onLongPress: () => PanaraConfirmDialog.show(
                context,
                title: "Delete this ?",
                message: 'Are you sure want to delete this ?',
                confirmButtonText: "Yes",
                cancelButtonText: "No",
                onTapCancel: () {
                  Navigator.pop(context);
                },
                onTapConfirm: () {
                  Navigator.pop(context);
                  final deleteUser = FirebaseFirestore.instance
                      .collection('history')
                      .doc(item.docID);
                  deleteUser.delete().then((_) => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Successfully delete history data'))));
                },
                panaraDialogType: PanaraDialogType.error,
                barrierDismissible: false,
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ResultScanQR(result: item.originalLink, onPop: (_) {}))),
            ),
          ),
        ),
      );

  Widget buildScanDocument(History item) => Padding(
        padding: EdgeInsets.only(top: 8, left: 8, right: 8),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text(item.type),
              subtitle: Text(DateFormat('dd/MM/yyyy')
                  .add_jm()
                  .format(DateTime.parse(item.date))
                  .toString()),
              onLongPress: () => PanaraConfirmDialog.show(
                context,
                title: "Delete this ?",
                message: 'Are you sure want to delete this ?',
                confirmButtonText: "Yes",
                cancelButtonText: "No",
                onTapCancel: () {
                  Navigator.pop(context);
                },
                onTapConfirm: () {
                  Navigator.pop(context);
                  final deleteUser = FirebaseFirestore.instance
                      .collection('history')
                      .doc(item.docID);
                  deleteUser.delete().then((_) => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Successfully delete history data'))));
                },
                panaraDialogType: PanaraDialogType.error,
                barrierDismissible: false,
              ),
              onTap: () => openFile(result: item.originalLink),
            ),
          ),
        ),
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

  Future<void> openFile({required String result}) async {
    final result2 = await OpenFilex.open(result);
    if (result2.type.toString() == "ResultType.fileNotFound") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Image maybe was deleted in your phone')),
      );
    }
    setState(() {});
  }
}
