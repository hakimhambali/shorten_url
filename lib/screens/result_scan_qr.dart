import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScanQR extends StatefulWidget {
  final String result;
  const ResultScanQR({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  State<ResultScanQR> createState() => _ResultScanQRState();
}

class _ResultScanQRState extends State<ResultScanQR> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Scanned QR code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Text(
              widget.result,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    icon: const Icon(Icons.content_copy),
                    onPressed: () async {
                      await FlutterClipboard.copy(widget.result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('✓   Copied to Clipboard')),
                      );
                    }),
                IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      var url = Uri.parse(widget.result);
                      launchURL(url);
                    }),
                IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      Share.share(widget.result);
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Text('Copy'),
                Text('Visit'),
                Text('Share'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> launchURL(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      return true;
    } else {
      return false;
    }
  }
}
