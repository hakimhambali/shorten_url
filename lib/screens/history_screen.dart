import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
// import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shorten_url/model/user.dart';
import 'package:shorten_url/screens/result_scan_qr.dart';
import 'package:url_launcher/url_launcher.dart';
import 'register.dart';
import 'view_qr.dart';

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
      appBar: AppBar(
        title: const Text('History'),
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
                  icon: const Icon(Icons.question_mark_outlined),
                  onPressed: () {
                    // showDialog(
                    //     context: context,
                    //     builder: (context) {
                    // return AlertDialog(
                    //   title: FirebaseAuth.instance.currentUser!.isAnonymous
                    //       ? const Text(
                    //           'You have not register yet. Register now to prevent any loss of your history data if you wish to uninstall this app or change devices. You can also login to your account if you have registered before.',
                    //           textAlign: TextAlign.center)
                    //       : const Text(
                    //           'Your history data are bind with your account. You have to logout in order to login to a different account or register a new account. Logout now ?',
                    //           textAlign: TextAlign.center),
                    //   content: SizedBox(
                    //     height: 80,
                    //     child: Column(
                    //       children: [
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 25.0),
                    //           child: Row(
                    //             mainAxisAlignment:
                    //                 MainAxisAlignment.spaceEvenly,
                    //             children: [
                    //               ElevatedButton(
                    //                   onPressed: () {
                    //                     Navigator.pop(context);
                    //                   },
                    //                   // icon: const Icon(Icons.close),
                    //                   child: FirebaseAuth.instance
                    //                           .currentUser!.isAnonymous
                    //                       ? const Text('Later')
                    //                       : const Text('No')),
                    //               ElevatedButton(
                    //                   onPressed: () {
                    //                     if (!FirebaseAuth.instance
                    //                         .currentUser!.isAnonymous) {
                    //                       FirebaseAuth.instance.signOut();
                    //                       FirebaseAuth.instance
                    //                           .signInAnonymously();
                    //                     }
                    //                     Navigator.pop(context);
                    //                     Navigator.push(
                    //                             context,
                    //                             MaterialPageRoute(
                    //                                 builder: (context) =>
                    //                                     const Register()))
                    //                         .then((value) {
                    //                       setState(() {});
                    //                     });
                    //                   },
                    //                   // icon: const Icon(Icons.check),
                    //                   child: FirebaseAuth.instance
                    //                           .currentUser!.isAnonymous
                    //                       ? const Text('Register Now')
                    //                       : const Text('Yes')),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // );
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
                      // barrierDismissible:
                      //     false, // optional parameter (default is true)
                    );
                    // });
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
                      barrierDismissible:
                          false, // optional parameter (default is true)
                    );
                    // });
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
              return const Center(child: CircularProgressIndicator());
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
              // onLongPress: () => showDialog(
              //     context: context,
              //     builder: (context) {
              //       return AlertDialog(
              //         title: const Text('Are you sure want to delete this ?',
              //             textAlign: TextAlign.center),
              //         content: SizedBox(
              //           height: 80,
              //           child: Column(
              //             children: [
              //               Padding(
              //                 padding: const EdgeInsets.only(top: 25.0),
              //                 child: Row(
              //                   mainAxisAlignment:
              //                       MainAxisAlignment.spaceEvenly,
              //                   children: [
              //                     ElevatedButton.icon(
              //                         onPressed: () {
              //                           Navigator.pop(context);
              //                         },
              //                         icon: const Icon(Icons.close),
              //                         label: const Text('No')),
              //                     ElevatedButton.icon(
              //                         onPressed: () {
              //                           Navigator.pop(context);
              //                           final deleteUser = FirebaseFirestore
              //                               .instance
              //                               .collection('history')
              //                               .doc(item.docID);
              //                           deleteUser.delete().then((_) =>
              //                               ScaffoldMessenger.of(context)
              //                                   .showSnackBar(const SnackBar(
              //                                       backgroundColor:
              //                                           Colors.green,
              //                                       content: Text(
              //                                           'Successfully delete history'))));
              //                         },
              //                         icon: const Icon(Icons.check),
              //                         label: const Text('Yes'))
              //                   ],
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       );
              //     }),
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
              onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: SizedBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                              text: item.originalLink))
                                          .then((_) => ScaffoldMessenger.of(
                                                  context)
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
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
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
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                              text: item.newLink))
                                          .then((_) => ScaffoldMessenger.of(
                                                  context)
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
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: const [
                                Text('Copy'),
                                Text('Visit'),
                                Text('Share'),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                  })
              // onTap: () => PanaraInfoDialog.show(
              //   context,
              //   title: "Hello",
              //   message: "This is the PanaraInfoDialog",
              //   buttonText: "Okay",
              //   onTapDismiss: () {
              //     Navigator.pop(context);
              //   },
              //   panaraDialogType: PanaraDialogType.normal,
              //   barrierDismissible:
              //       false, // optional parameter (default is true)
              // ),
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
              // builder: (context) => ViewQR(item.originalLink, item.newLink))),
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
                  // builder: (context) => ScanQR(link: item.originalLink))),
                  builder: (context) => ResultScanQR(
                        result: item.originalLink,
                      ))),
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
      // .orderBy('date', descending: false)
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
    await OpenFilex.open(result);
    setState(() {});
  }
}
