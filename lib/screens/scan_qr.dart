import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQR extends StatefulWidget {
  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  final GlobalKey _globalKey = GlobalKey();
  QRViewController? controller;
  Barcode? result;
  void qr(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((event) {
      setState(() {
        result = event;
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
            result == null
                ? SizedBox(
                    // height: (result == null) ? 400 : 0,
                    // width: (result == null) ? 300 : 0,
                    // child: (result == null)
                    //     ? QRView(key: _globalKey, onQRViewCreated: qr)
                    //     : null,
                    height: 400,
                    width: 300,
                    child: QRView(key: _globalKey, onQRViewCreated: qr))
                : const SizedBox(),
            Center(
                child: (result != null)
                    ? Text(
                        '${result!.code}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )
                    : Container(
                        margin: const EdgeInsets.only(top: 30.0),
                        child: const Text('Tap to start scanning QR code'),
                      )),
            result != null
                ? Row(
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
                  )
                : Row(),
            result != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text('Copy'),
                      Text('Visit'),
                      Text('Share'),
                    ],
                  )
                : Row(),
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
}
