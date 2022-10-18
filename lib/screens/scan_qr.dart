import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
        showDialog(
            context: context,
            builder: (context) {
              // result = null;
              return AlertDialog(
                title: const Text('QR Scanned Successfully'),
                content: SizedBox(
                  height: 100,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {},
                            child: Container(
                              color: Colors.grey.withOpacity(.2),
                              child: Text(result.toString()),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                        ClipboardData(text: result.toString()))
                                    .then((_) => ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Urls is copied to the clipboard'))));
                              },
                              icon: const Icon(Icons.copy))
                        ],
                      ),
                      ElevatedButton.icon(
                          onPressed: () {
                            // result = null;
                            // controller.clear();
                            Navigator.pop(context);
                            result = null;
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Close'))
                    ],
                  ),
                ),
              );
            });
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
                : Container(),
            SizedBox(height: 16),
            Center(
              child: (result != null)
                  ? Text(
                      '${result!.code}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    )
                  : const Text('Tap to start scanning QR code'),
            ),
          ],
        ),
        // child: QRView(
        //   key: _globalKey
        //   onQRViewCreated: qr,
        // ),
      ),
    );
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Your Name'),
          content: const TextField(
            decoration: InputDecoration(hintText: 'Enter Your Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                result = null;
              },
              child: const Text('SUBMIT'),
            ),
          ],
        ),
      );
}
