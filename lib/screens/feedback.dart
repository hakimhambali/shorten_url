import 'package:flutter/material.dart';
import 'package:shorten_url/main.dart';

class Improvement extends StatefulWidget {
  const Improvement({Key? key}) : super(key: key);

  @override
  State<Improvement> createState() => _ImprovementState();
}

class _ImprovementState extends State<Improvement> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Container(
        padding: const EdgeInsets.all(24.30),
        child: Column(
          children: [
            const Text(
              'In order to serve the best for you, We would love to hear your feedback !',
              textAlign: TextAlign.center,
            ),
            TextFormField(
              // validator: (String? input){
                
              // },
              controller: controller,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 150.0, horizontal: 10.0),
                  labelText: 'Enter your Feedback here',
                  // hintText: 'Amazing UI and functionalities but...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(
              height: 30,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            // ElevatedButton(
            //   onPressed: () async {
            //     final shortenedUrl = await shortenUrl(url: controller.text);
            //     if (shortenedUrl != null) {
            //       showDialog(
            //           context: context,
            //           builder: (context) {
            //             return AlertDialog(
            //               title: const Text('Url Shortened Successfully'),
            //               content: SizedBox(
            //                 height: 100,
            //                 child: Column(
            //                   children: [
            //                     Row(
            //                       children: [
            //                         GestureDetector(
            //                           onTap: () async {
            //                             if (await canLaunch(shortenedUrl)) {
            //                               await launch(shortenedUrl);
            //                             }
            //                           },
            //                           child: Container(
            //                             color: Colors.grey.withOpacity(.2),
            //                             child: Text(shortenedUrl),
            //                           ),
            //                         ),
            //                         IconButton(
            //                             onPressed: () {
            //                               Clipboard.setData(ClipboardData(
            //                                       text: shortenedUrl))
            //                                   .then((_) => ScaffoldMessenger
            //                                           .of(context)
            //                                       .showSnackBar(const SnackBar(
            //                                           content: Text(
            //                                               'Urls is copied to the clipboard'))));
            //                             },
            //                             icon: const Icon(Icons.copy))
            //                       ],
            //                     ),
            //                     ElevatedButton.icon(
            //                         onPressed: () {
            //                           controller.clear();
            //                           Navigator.pop(context);
            //                         },
            //                         icon: const Icon(Icons.close),
            //                         label: const Text('Close'))
            //                   ],
            //                 ),
            //               ),
            //             );
            //           });
            //     }
            //   },
            //   child: const Text('Submit'),
            // ),
            // ],
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Home()));
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
