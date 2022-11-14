import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQR extends StatefulWidget {
  final String link;
  const ScanQR({
    Key? key,
    required this.link,
  }) : super(key: key);

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  DateTime now = DateTime.now();
  final GlobalKey _globalKey = GlobalKey();
  QRViewController? controller;
  Barcode? result;
  void qr(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((event) {
      setState(() {
        result = event;
        createScanQRHistory(
            originalLink: result!.code!,
            newLink: result!.code!,
            date: now.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            result == null && widget.link == ''
                ? SizedBox(
                    height: 400,
                    width: 300,
                    child: QRView(key: _globalKey, onQRViewCreated: qr))
                // : result == null && widget.link != ''
                //     ? SizedBox(
                //         height: 400,
                //         width: 300,
                //         child: QRView(key: _globalKey, onQRViewCreated: qr))
                : const SizedBox(),
            Center(
                child: (result == null && widget.link == '')
                    ? Container(
                        margin: const EdgeInsets.only(top: 30.0),
                        child: const Text('Tap to start scanning QR code'),
                      )
                    : (result == null && widget.link != '')
                        ? Text(
                            widget.link,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            '${result!.code}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )),
            result == null && widget.link == ''
                ? Row()
                : result == null && widget.link != ''
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.content_copy),
                              onPressed: () async {
                                await FlutterClipboard.copy(widget.link);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('✓   Copied to Clipboard')),
                                );
                              }),
                          IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                var url = Uri.parse(widget.link);
                                launchURL(url);
                              }),
                          IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                Share.share(widget.link);
                              }),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.content_copy),
                              onPressed: () async {
                                await FlutterClipboard.copy('${result!.code}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('✓   Copied to Clipboard')),
                                );
                              }),
                          IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                var url = Uri.parse('${result!.code}');
                                launchURL(url);
                              }),
                          IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                Share.share('${result!.code}');
                              }),
                        ],
                      ),
            result == null && widget.link == ''
                ? Row()
                // : result == null && widget.link != ''
                //     ? Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //         children: const [
                //           Text('Copy'),
                //           Text('Visit'),
                //           Text('Share'),
                //         ],
                //       )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text('Copy'),
                      Text('Visit'),
                      Text('Share'),
                    ],
                  ),
          ],
        ),
        // child: QRView(
        //   key: _globalKey,
        //   onQRViewCreated: qr,
        // ),
      ),
    );
  }

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

  Future createScanQRHistory(
      {required String originalLink, newLink, required String date}) async {
    final historyUser = FirebaseFirestore.instance.collection('history').doc();
    final json = {
      'docID': historyUser.id,
      'originalLink': originalLink,
      'newLink': newLink,
      'date': date,
      'type': "Scan QR",
      'userID': FirebaseAuth.instance.currentUser!.uid.toString()
    };
    await historyUser.set(json);
  }
}