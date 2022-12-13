import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shorten_url/screens/scan_document.dart';
import 'package:shorten_url/screens/scan_qr.dart';
import 'package:shorten_url/screens/result_generate_qr.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final controller = TextEditingController();
  bool validate = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('MasterZ'),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () async {
              AwesomeDialog(
                context: context,
                animType: AnimType.scale,
                dialogType: DialogType.noHeader,
                body: SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text('4 features of MasterZ are: \n\n',
                                style: TextStyle(fontSize: 20)),
                            new Align(
                                alignment: Alignment.centerLeft,
                                child: new Text('1. Shorten URL: Shorten links\n',
                                    style: TextStyle(fontSize: 16))),
                            new Align(
                                alignment: Alignment.centerLeft,
                                child: new Text(
                                    '2. Generate QR: Generate QR code from links\n',
                                    style: TextStyle(fontSize: 16))),
                            new Align(
                                alignment: Alignment.centerLeft,
                                child: new Text(
                                    '3. Scan QR: Scan QR code to links\n',
                                    style: TextStyle(fontSize: 16))),
                            new Align(
                                alignment: Alignment.centerLeft,
                                child: new Text(
                                    '4. Scan Document: Scan document using camera\n',
                                    style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                title: 'This is Ignored',
                desc: 'This is also Ignored',
                btnOkOnPress: () {},
              )..show();
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Column(
                children: [
                  TextFormField(
                    controller: controller,
                    onChanged: (value) {
                      setState(() {
                        validate = validateURL(value);
                      });
                    },
                    decoration: InputDecoration(
                        labelText: 'Enter your url here',
                        hintText: 'https://www.example.com',
                        errorText: validate ? null : "Please insert valid url",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 132.0,
                        height: 40.0,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0))),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.purple.shade900)),
                          onPressed: () async {
                            validate = validateURL(controller.text);
                            setState(() {});
                            if (validate && controller.text.isNotEmpty) {
                              final shortenedUrl =
                                  await shortenUrl(url: controller.text);
                              if (shortenedUrl != null) {
                                createShortUrlHistory(
                                    originalLink: controller.text,
                                    newLink: shortenedUrl,
                                    date: DateTime.now().toString());
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor: Colors.green,
                                      content:
                                          Text('Successfully shorten URL')),
                                );
                                AwesomeDialog(
                                  context: context,
                                  animType: AnimType.scale,
                                  dialogType: DialogType.success,
                                  body: SizedBox(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {},
                                              child: Container(
                                                color:
                                                    Colors.grey.withOpacity(.2),
                                                child: Text(
                                                  shortenedUrl,
                                                  style:
                                                      TextStyle(fontSize: 19),
                                                ),
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
                                                  Clipboard.setData(
                                                          ClipboardData(
                                                              text:
                                                                  shortenedUrl))
                                                      .then((_) => ScaffoldMessenger
                                                              .of(context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Urls is copied to the clipboard'))));
                                                },
                                                icon: const Icon(Icons.copy)),
                                            IconButton(
                                                icon: const Icon(Icons.search),
                                                onPressed: () {
                                                  var url =
                                                      Uri.parse(shortenedUrl);
                                                  launchURL(url);
                                                }),
                                            IconButton(
                                                icon: const Icon(Icons.share),
                                                onPressed: () {
                                                  Share.share(shortenedUrl);
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
                                      ],
                                    ),
                                  ),
                                  title: 'This is Ignored',
                                  desc: 'This is also Ignored',
                                  btnOkOnPress: () {
                                    controller.clear();
                                  },
                                )..show();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                          'URL does not exists or poor internet connection')),
                                );
                              }
                            }
                          },
                          child: const Text('Shorten url'),
                        ),
                      ),
                      const Text("or"),
                      SizedBox(
                        width: 132.0,
                        height: 40.0,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0))),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.purple.shade900)),
                          onPressed: () async {
                            validate = validateURL(controller.text);
                            setState(() {});
                            if (validate && controller.text.isNotEmpty) {
                              final shortenedUrl =
                                  await shortenUrl(url: controller.text);
                              if (shortenedUrl != null) {
                                final generateQR =
                                    await shortenUrl(url: controller.text);
                                if (generateQR != null) {
                                  createGenerateQRHistory(
                                      originalLink: controller.text,
                                      newLink: controller.text,
                                      date: DateTime.now().toString());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: Colors.green,
                                        content:
                                            Text('Successfully Generate QR')),
                                  );
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ViewQR(
                                            originalLink: controller.text,
                                            newLink: '',
                                          )));
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                          'URL does not exists or poor internet connection')),
                                );
                              }
                            }
                          },
                          child: const Text('Generate QR'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 70,
            ),
            Container(
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 132.0,
                    height: 40.0,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0))),
                          backgroundColor: MaterialStateProperty.all(
                              Colors.purple.shade900)),
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ScanQR()));
                      },
                      child: const Text('Scan QR'),
                    ),
                  ),
                  const Text("or"),
                  SizedBox(
                    width: 132.0,
                    height: 40.0,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0))),
                          backgroundColor: MaterialStateProperty.all(
                              Colors.purple.shade900)),
                      onPressed: () async {
                        try {
                          File? scannedDoc =
                              await CustomDocumentScannerFlutter.launch(context,
                                  source: ScannerFileSource.CAMERA);
                        } on PlatformException {}
                      },
                      child: const Text('Scan Document'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> shortenUrl({required String url}) async {
    try {
      if (url.startsWith('http://')) {
        final splitted = url.split(':');
        url = 'https:' + splitted[1];
      } else {
        if (url.startsWith('https://')) {
        } else {
          url = 'https://' + url;
        }
      }

      final result = await http.post(
          Uri.parse('https://cleanuri.com/api/v1/shorten'),
          body: {'url': url});

      if (result.statusCode == 200) {
        final jsonResult = jsonDecode(result.body);
        return jsonResult['result_url'];
      }
    } catch (e) {
      print('Error ${e.toString()}');
    }
    return null;
  }

  bool validateURL(String val) {
    if (RegExp(
            r'(^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$)')
        .hasMatch(val)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> launchURL(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      return true;
    } else {
      return false;
    }
  }

  Future createShortUrlHistory(
      {required String originalLink, newLink, required String date}) async {
    final historyUser = FirebaseFirestore.instance.collection('history').doc();
    final json = {
      'docID': historyUser.id,
      'originalLink': originalLink,
      'newLink': newLink,
      'date': date,
      'type': "Shorten URL",
      'userID': FirebaseAuth.instance.currentUser!.uid.toString()
    };
    await historyUser.set(json);
  }

  Future createGenerateQRHistory(
      {required String originalLink, newLink, required String date}) async {
    final historyUser = FirebaseFirestore.instance.collection('history').doc();
    final json = {
      'docID': historyUser.id,
      'originalLink': originalLink,
      'newLink': newLink,
      'date': date,
      'type': "Generate QR",
      'userID': FirebaseAuth.instance.currentUser!.uid.toString()
    };
    await historyUser.set(json);
  }
}
