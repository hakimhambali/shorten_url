import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart' as eos;
import 'package:shorten_url/screens/result_scan_text.dart';

class ScanText extends StatefulWidget {
  const ScanText({super.key});

  @override
  State<ScanText> createState() => _ScanTextState();
}

class _ScanTextState extends State<ScanText> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  eos.QRViewController? controller;
  eos.Barcode? result;

  bool textScanning = false;
  XFile? imageFile;
  String scannedText = "";

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
              Positioned(top: 10, child: buildTopButtons()),
              Positioned(bottom: 35, child: buildBotButtons()),
            ],
          ),
        ),
      );

  Widget buildQRView(BuildContext context) => eos.QRView(
        key: qrKey,
        onQRViewCreated: onQRGenerated,
        // overlay: eos.QrScannerOverlayShape(
        //   borderColor: Theme.of(context).colorScheme.secondary,
        //   borderRadius: 10,
        //   borderLength: 20,
        //   borderWidth: 10,
        //   cutOutSize: MediaQuery.of(context).size.width * 0.8,
        // ),
      );

  void onQRGenerated(eos.QRViewController controller) {
    this.controller = controller;
    controller.resumeCamera();
    controller.scannedDataStream.listen((event) {
      setState(() async {
        result = event;
        createScanTextHistory(
            originalLink: result!.code!,
            newLink: result!.code!,
            date: DateTime.now().toString());
        if (result != null) {
          await controller.pauseCamera();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResultScanText(
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

  Widget buildTopButtons() => Container(
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
                getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      );

  Widget buildBotButtons() => Container(
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
              icon: const Icon(Icons.circle_sharp),
              onPressed: () async {
                getImage(ImageSource.camera);
              },
            ),
          ],
        ),
      );

  Future createScanTextHistory(
      {required String originalLink, newLink, required String date}) async {
    final historyUser = FirebaseFirestore.instance.collection('history').doc();
    final json = {
      'docID': historyUser.id,
      'originalLink': originalLink,
      'newLink': newLink,
      'date': date,
      'type': "Scan Text",
      'userID': FirebaseAuth.instance.currentUser!.uid.toString()
    };
    await historyUser.set(json);
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      setState(() {});
      scannedText = "Error occured while scanning";
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    debugPrint(inputImage.toString());
    // final textDetector = GoogleMlKit.vision.textRecognizer();
    final TextRecognizer textDetector = TextRecognizer();
    RecognizedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
      }
    }
    textScanning = false;
    debugPrint('scannedText1: ' + recognisedText.toString());
    debugPrint('scannedText2: ' + scannedText.characters.string);
    setState(() {});

    if (scannedText != '') {
      setState(() async {
        createScanTextHistory(
            originalLink: scannedText,
            newLink: scannedText,
            date: DateTime.now().toString());
        await controller!.pauseCamera();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResultScanText(
                    result: scannedText,
                    onPop: (resume) {
                      debugPrint('RESUME');
                      assembleCamera();
                    })));
      });
    } else {
      PanaraInfoDialog.show(
        context,
        title: "Unable to detect any text",
        message: 'Are you sure upload the correct Text file ? Please try again',
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
