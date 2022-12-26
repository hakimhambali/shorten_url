import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/screens/pdf_generator_gallery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';

class CustomDocumentScannerFlutter {
  static MethodChannel get _channel =>
      const MethodChannel('document_scanner_flutter');

  static Future<File?> _scanDocument(
      ScannerFileSource source, Map<dynamic, String> androidConfigs) async {
    Map<String, String?> finalAndroidArgs = {};
    for (var entry in androidConfigs.entries) {
      finalAndroidArgs[describeEnum(entry.key)] = entry.value;
    }

    String? path = await _channel.invokeMethod(
        describeEnum(source).toLowerCase(), finalAndroidArgs);
    if (path == null) {
      return null;
    } else {
      if (Platform.isIOS) {
        path = path.split('file://')[1];
      }
      createScanDocumentHistory(
          date: DateTime.now().toString(), newLink: path, originalLink: path);
      // debugPrint(path);
      OpenFilex.open(path);
      // ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(
      //   const SnackBar(
      //       backgroundColor: Colors.green,
      //       content: Text('Successfully scan document')),
      // );
      return File(path);
    }
  }

  static Future<File?> launchForPdf(BuildContext context,
      {ScannerFileSource? source,
      Map<dynamic, String> labelsConfig = const {}}) async {
    Future<File?>? launchWrapper() {
      return launch(context, labelsConfig: labelsConfig, source: source);
    }

    return await Navigator.push<File>(
        context,
        MaterialPageRoute(
            builder: (_) => PdfGeneratotGallery(launchWrapper, labelsConfig)));
  }

  static Future<File?>? launch(BuildContext context,
      {ScannerFileSource? source,
      Map<dynamic, String> labelsConfig = const {}}) {
    if (source != null) {
      return _scanDocument(source, labelsConfig);
    }
    return showModalBottomSheet<File>(
        context: context,
        builder: (BuildContext bc) {
          return Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(
                      labelsConfig[ScannerLabelsConfig.PICKER_CAMERA_LABEL] ??
                          'Camera'),
                  onTap: () async {
                    Navigator.pop(
                        context,
                        await _scanDocument(
                            ScannerFileSource.CAMERA, labelsConfig));
                  }),
              ListTile(
                leading: const Icon(Icons.image_search),
                title: Text(
                    labelsConfig[ScannerLabelsConfig.PICKER_GALLERY_LABEL] ??
                        'Photo Library'),
                onTap: () async {
                  Navigator.pop(
                      context,
                      await _scanDocument(
                          ScannerFileSource.GALLERY, labelsConfig));
                },
              ),
            ],
          );
        });
  }

  static Future createScanDocumentHistory(
      {required String originalLink, newLink, required String date}) async {
    final historyUser = FirebaseFirestore.instance.collection('history').doc();
    final json = {
      'docID': historyUser.id,
      'originalLink': originalLink,
      'newLink': newLink,
      'date': date,
      'type': "Scan Document",
      'userID': FirebaseAuth.instance.currentUser!.uid.toString()
    };
    await historyUser.set(json);
  }
}
