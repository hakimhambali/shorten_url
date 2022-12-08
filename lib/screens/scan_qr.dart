import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart' as eos;

import 'result_scan_qr.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  eos.QRViewController? controller;
  eos.Barcode? result;

  bool imageLabelChecking = false;
  XFile? imageFile;
  String imageLabel = "";

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    assembleCamera();
  }

  assembleCamera() async {
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
              Positioned(top: 10, child: buildControlButtons()),
            ],
          ),
        ),
      );

  Widget buildQRView(BuildContext context) => eos.QRView(
        key: qrKey,
        onQRViewCreated: onQRGenerated,
        overlay: eos.QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.secondary,
          borderRadius: 10,
          borderLength: 20,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      );

  Widget buildImageView(image) => eos.QRView(
        key: qrKey,
        onQRViewCreated: onQRGenerated,
        overlay: eos.QrScannerOverlayShape(
          borderColor: Theme.of(image).colorScheme.secondary,
          borderRadius: 10,
          borderLength: 20,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(image).size.width * 0.8,
        ),
      );

  void onQRGenerated(eos.QRViewController controller) {
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
                    onPop: (resume) {
                      debugPrint('RESUME');
                      assembleCamera();
                    })),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Successfully Scan QR')),
          );
        }
      });
    });
  }

  Widget buildControlButtons() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white24,
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
              onPressed: () {
                getImage();
              },
            ),
          ],
        ),
      );

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

  void getImage() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        imageLabelChecking = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedQR(pickedImage);
      }
    } catch (e) {
      imageLabelChecking = false;
      imageFile = null;
      setState(() {});
    }
  }

  void getRecognisedQR(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    final barcodeScanner = BarcodeScanner(formats: formats);
    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);

    if (barcodes.length >= 1) {
      for (Barcode barcode in barcodes) {
        setState(() async {
          createScanQRHistory(
              originalLink: barcode.displayValue.toString(),
              newLink: barcode.displayValue.toString(),
              date: DateTime.now().toString());
          await controller!.pauseCamera();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ResultScanQR(
                      result: barcode.displayValue.toString(),
                      onPop: (resume) {
                        debugPrint('RESUME');
                        assembleCamera();
                      })));
        });
      }
    } else {
      PanaraInfoDialog.show(
        context,
        title: "Unable to detect QR code",
        message:
            'Are you sure upload the correct QR code file ? or please try again',
        buttonText: "Close",
        onTapDismiss: () {
          Navigator.pop(context);
        },
        panaraDialogType: PanaraDialogType.error,
        barrierDismissible: false,
      );
    }
  }
}
