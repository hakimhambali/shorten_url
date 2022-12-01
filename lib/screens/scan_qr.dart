import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
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

  // TEST UPLOAD IMAGE FROM GALLERY START
  bool imageLabelChecking = false;
  XFile? imageFile;
  String imageLabel = "";
  // TEST UPLOAD IMAGE FROM GALLERY END

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
              // TEST UPLOAD IMAGE FROM GALLERY START
              // if (textScanning) const CircularProgressIndicator(),
              // if (!textScanning && imageFile == null) buildQRView(context),
              // if (imageFile != null)
              //   buildImageView(Image.file(File(imageFile!.path))),
              if (imageFile != null)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.vertical,
                  child: Image.file(
                    File(imageFile!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              // Positioned(bottom: 10, child: buildResult()),
              // TEST UPLOAD IMAGE FROM GALLERY END

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

  // TEST UPLOAD IMAGE FROM GALLERY START
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
  // TEST UPLOAD IMAGE FROM GALLERY END

  // void onQRViewCreated(QRViewController controller) {
  //   setState(() => this.controller = controller);

  //   controller.scannedDataStream
  //       .listen((barcode) => setState(() => this.barcode = barcode));
  // }

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
              onPressed: () {
                getImage();
              },
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

  // Future<void> openFile() async {
  //   // debugPrint(result.code);
  //   const filePath = '/storage/emulated/0/Pictures/1668674414462.jpg';
  //   await OpenFilex.open(filePath);
  //   // await OpenFilex.open(filePath);
  //   setState(() {});
  //   // setState(() {
  //   //   // _openResult = "type=${result.type}  message=${result.message}";
  //   // });
  // }

  // TEST UPLOAD IMAGE FROM GALLERY START
  void getImage() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        imageLabelChecking = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      imageLabelChecking = false;
      imageFile = null;
      setState(() {});
      // scannedText = "Error occured while scanning";
    }
  }

  // void getRecognisedText(XFile image) async {
  //   final inputImage = InputImage.fromFilePath(image.path);
  //   debugPrint(inputImage.toString());
  //   final textDetector = GoogleMlKit.vision.barcodeScanner();
  //   List<Barcode> recognisedText = await textDetector.processImage(inputImage);
  //   await textDetector.close();
  //   scannedText = recognisedText.toString();
  //   // for (TextBlock block in recognisedText.blocks) {
  //   //   for (TextLine line in block.lines) {
  //   //     scannedText = scannedText + line.text + "\n";
  //   //   }
  //   // }
  //   textScanning = false;
  //   print('scannedText: ' + scannedText);
  //   setState(() {});
  // }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    ImageLabeler imageLabeler =
        ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.75));
    List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    StringBuffer sb = StringBuffer();
    for (ImageLabel imgLabel in labels) {
      String lblText = imgLabel.label;
      double confidence = imgLabel.confidence;
      sb.write(lblText);
      sb.write(" : ");
      sb.write((confidence * 100).toStringAsFixed(2));
      sb.write("%\n");
    }
    imageLabeler.close();
    imageLabel = sb.toString();
    imageLabelChecking = false;
    print('scannedText: ' + imageLabel);
    setState(() {});
  }
  // TEST UPLOAD IMAGE FROM GALLERY END
}
