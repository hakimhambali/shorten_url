import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:scan/scan.dart';

import 'result_scan_qr.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();

    if (Platform.isAndroid) {
      await controller!
          .pauseCamera()
          .whenComplete(() => controller!.resumeCamera().whenComplete(() {
                setState(() {});
              }));
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              buildQRView(context),
              // Positioned(bottom: 10, child: buildResult()),
              Positioned(top: 10, child: buildControlButtons()),
            ],
          ),
        ),
      );

  Widget buildQRView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRGenerated,
        overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.secondary,
          borderRadius: 10,
          borderLength: 20,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      );

  // void onQRViewCreated(QRViewController controller) {
  //   setState(() => this.controller = controller);

  //   controller.scannedDataStream
  //       .listen((barcode) => setState(() => this.barcode = barcode));
  // }

  void onQRGenerated(QRViewController controller) {
    this.controller = controller;
    controller.resumeCamera();
    controller.scannedDataStream.listen((event) {
      setState(() async {
        result = event;
        createScanQRHistory(
            originalLink: result!.code!,
            newLink: result!.code!,
            date: DateTime.now().toString());
        if (result != null) {
          await controller.pauseCamera();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ResultScanQR(
                        result: '${result!.code}',
                      )));
        }
      });
    });
  }

  // Widget buildResult() => Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(8),
  //         color: Colors.white24,
  //       ),
  //       child: Text(
  //         result != null ? 'Result : ${result!.code}' : 'Scan a code !',
  //         maxLines: 3,
  //       ),
  //     );

  Widget buildControlButtons() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white24,
          // color: Colors.blue.withOpacity(0.25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () async {
                await controller?.toggleFlash();
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.switch_camera),
              onPressed: () async {
                await controller?.flipCamera();
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.image),
              // onPressed: () async {
              //   debugPrint('john');
              //   // String? test = await Scan.parse('gallery');
              //   // await controller?.flipCamera();
              //   setState(() {});
              // },
              // onPressed: () async => pickImage(),
              // icon: Icon(Icons.image),
              // // label: Text("Choose an Image from gallery"),
              onPressed: openFile,
            ),
          ],
        ),
      );

  // Future<void> pickImage() async {
  //   await Permission.storage.request();
  //   var status = await Permission.storage.status;

  //   if (status.isGranted) {
  //     final pickedFile =
  //         await ImagePicker().pickImage(source: ImageSource.gallery);
  //     if (pickedFile != null) {
  //       setState(
  //         () {
  //           this._image = File(pickedFile.path);
  //         },
  //       );
  //     }
  //   }
  // }

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

  Future<void> openFile() async {
    // debugPrint(result.code);
    const filePath = '/storage/emulated/0/Pictures/1668674414462.jpg';
    await OpenFilex.open(filePath);
    // await OpenFilex.open(filePath);
    setState(() {});
    // setState(() {
    //   // _openResult = "type=${result.type}  message=${result.message}";
    // });
  }
}
