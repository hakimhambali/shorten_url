import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScanDocument extends StatefulWidget {
  final String result;
  const ResultScanDocument({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  State<ResultScanDocument> createState() => _ResultScanDocumentState();
}

class _ResultScanDocumentState extends State<ResultScanDocument> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Scanned Document'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Center(child: OpenFilex.open(widget.result)),
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
