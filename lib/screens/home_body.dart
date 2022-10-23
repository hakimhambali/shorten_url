import 'dart:convert';
import 'dart:io';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shorten_url/screens/scan_document.dart';
import 'package:shorten_url/screens/scan_qr.dart';
import 'package:shorten_url/screens/view_qr.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
// START SHAREDPREFERNCES
  // String date = '';
  // late SharedPreferences preferences;
  // @override
  // void initState() {
  //   super.initState();

  //   init();
  // }

  // Future init() async {
  //   preferences = await SharedPreferences.getInstance();

  // String? date = preferences.getString("date");
  // if (date == null) return;

  // setState(() => this.date = date);
  // }
// END SHAREDPREFERNCES

  // final now = DateTime.now();
  final controller = TextEditingController();
  bool validate = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR & Link'),
        // centerTitle: true,
        // backgroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Container(
              // color: Colors.blue,
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
                          onPressed: () async {
                            validate = validateURL(controller.text);
                            setState(() {});
                            if (validate && controller.text.isNotEmpty) {
                              final shortenedUrl =
                                  await shortenUrl(url: controller.text);
                              if (shortenedUrl != null) {
// START SHAREDPREFERNCES
                                // print(now.toString());
                                // String formatter =
                                //     DateFormat('yMd').format(now);

                                // final surl = Surl(
                                //   link: shortenedUrl,
                                //   date: now.toString(),
                                // );
                                // final surlJson = json.encode(surl.toJson());
                                // preferences.setString("surl", surlJson);
                                // print(shortenedUrl);
                                // print(surlJson);
// END SHAREDPREFERNCES

                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Url Shortened Successfully'),
                                        content: SizedBox(
                                          height: 160,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      // if (await canLaunch(
                                                      //     shortenedUrl)) {
                                                      //   await launch(shortenedUrl);
                                                      // }
                                                    },
                                                    child: Container(
                                                      color: Colors.grey
                                                          .withOpacity(.2),
                                                      child: Text(shortenedUrl),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                                        content:
                                                                            Text('Urls is copied to the clipboard'))));
                                                      },
                                                      icon: const Icon(
                                                          Icons.copy)),
                                                  IconButton(
                                                      icon: const Icon(
                                                          Icons.search),
                                                      onPressed: () {
                                                        var url = Uri.parse(
                                                            shortenedUrl);
                                                        launchURL(url);
                                                      }),
                                                  IconButton(
                                                      icon: const Icon(
                                                          Icons.share),
                                                      onPressed: () {
                                                        Share.share(
                                                            shortenedUrl);
                                                      }),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: const [
                                                  Text('Copy'),
                                                  Text('Visit'),
                                                  Text('Share'),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 25.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    ElevatedButton.icon(
                                                        onPressed: () {
                                                          controller.clear();
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        icon: const Icon(
                                                            Icons.close),
                                                        label:
                                                            const Text('Close'))
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
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
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          ViewQR(controller.text)));
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
                  // Row(
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () async {
                  //         Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: (context) => DocumentScannerFlutter()));
                  //       },
                  //       child: const Text('Scan Document'),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            const SizedBox(
              height: 70,
            ),
            Container(
              // color: Colors.red,
              // child: Padding(
              //   padding:
              //       const EdgeInsets.symmetric(vertical: 80.0, horizontal: 0.0),
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
                      onPressed: () async {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => ScanQR()));
                      },
                      child: const Text('Scan QR'),
                    ),
                  ),
                  const Text("or"),
                  SizedBox(
                    width: 132.0,
                    height: 40.0,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          File? scannedDoc =
                              await CustomDocumentScannerFlutter.launch(context,
                                  source: ScannerFileSource
                                      .CAMERA); // Or ScannerFileSource.GALLERY
                          // `scannedDoc` will be the image file scanned from scanner
                        } on PlatformException {
                          // 'Failed to get document path or operation cancelled!';
                        }
                      },
                      child: const Text('Scan Document'),
                    ),
                  ),
                ],
              ),
              // ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> shortenUrl({required String url}) async {
    try {
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
      print("launched URL: $url");
      return true;
    } else {
      print('Could not launch $url');
      return false;
    }
  }
}

// START SHAREDPREFERNCES
// class Surl {
//   final String link;
//   final String date;

//   const Surl({
//     required this.link,
//     required this.date,
//   });

//   static Surl fromJson(Map<String, dynamic> json) => Surl(
//         link: json["link"],
//         date: json["date"],
//       );

//   Map<String, dynamic> toJson() => {
//         'link': link,
//         'date': date,
//       };
// }
// END SHAREDPREFERNCES