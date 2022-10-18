import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shorten_url/screens/scan_qr.dart';
import 'package:shorten_url/screens/view_qr.dart';

import 'package:http/http.dart' as http;

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
      appBar: AppBar(
        title: const Text('QR & Link'),
        // centerTitle: true,
        // backgroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
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
                ElevatedButton(
                  onPressed: () async {
                    validate = validateURL(controller.text);
                    setState(() {});
                    if (validate && controller.text.isNotEmpty) {
                      final shortenedUrl =
                          await shortenUrl(url: controller.text);
                      if (shortenedUrl != null) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Url Shortened Successfully'),
                                content: SizedBox(
                                  height: 100,
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
                                              color:
                                                  Colors.grey.withOpacity(.2),
                                              child: Text(shortenedUrl),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                        text: shortenedUrl))
                                                    .then((_) => ScaffoldMessenger
                                                            .of(context)
                                                        .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'Urls is copied to the clipboard'))));
                                              },
                                              icon: const Icon(Icons.copy))
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                          onPressed: () {
                                            controller.clear();
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(Icons.close),
                                          label: const Text('Close'))
                                    ],
                                  ),
                                ),
                              );
                            });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('URL does not exists')),
                        );
                      }
                    }
                  },
                  child: const Text('Shorten url'),
                ),
                const Text("or"),
                ElevatedButton(
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
                              builder: (context) => ViewQR(controller.text)));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('URL does not exists')),
                        );
                      }
                    }
                  },
                  child: const Text('Generate QR'),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ScanQR()));
                  },
                  child: const Text('Scan QR'),
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
}
