// import 'package:flutter/material.dart';
// import 'package:clipboard/clipboard.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ScanQRHistory extends StatefulWidget {
//   String url;
//   late String url2;
//   ScanQRHistory(this.url, String newLink, {Key? key}) : super(key: key);

//   @override
//   State<ScanQRHistory> createState() => _ScanQRHistoryState();
// }

// class _ScanQRHistoryState extends State<ScanQRHistory> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan QR code'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const SizedBox(),
//             Center(
//                 child: Text(
//               '${url!.code}',
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             )),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(
//                     icon: const Icon(Icons.content_copy),
//                     onPressed: () async {
//                       await FlutterClipboard.copy('${result!.code}');
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text('✓   Copied to Clipboard')),
//                       );
//                     }),
//                 IconButton(
//                     icon: const Icon(Icons.search),
//                     onPressed: () {
//                       var url = Uri.parse('${result!.code}');
//                       launchURL(url);
//                     }),
//                 IconButton(
//                     icon: const Icon(Icons.share),
//                     onPressed: () {
//                       Share.share('${result!.code}');
//                     }),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: const [
//                 Text('Copy'),
//                 Text('Visit'),
//                 Text('Share'),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Future<bool> launchURL(url) async {
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//       print("launched URL: $url");
//       return true;
//     } else {
//       print('Could not launch $url');
//       return false;
//     }
//   }
// }
