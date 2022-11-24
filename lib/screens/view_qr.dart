import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/qr_code_widget.dart';

class ViewQR extends StatefulWidget {
  final String originalLink;
  final String newLink;
  const ViewQR({
    Key? key,
    required this.originalLink,
    required this.newLink,
  }) : super(key: key);

  // String url;
  // late String newLink;
  // ViewQR(this.url, String newLink, {Key? key}) : super(key: key);

  @override
  State<ViewQR> createState() => _ViewQRState();
}

class _ViewQRState extends State<ViewQR> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View QR link'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Column(
              children: [
                Center(
                  child: QRCode(
                    qrSize: 320,
                    qrData: widget.originalLink,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                (widget.newLink != '')
                    ? Text(
                        widget.newLink,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )
                    : Container(),
              ],
            )),
            (widget.newLink != '')
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.content_copy),
                          onPressed: () async {
                            await FlutterClipboard.copy(widget.newLink);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('✓   Copied to Clipboard')),
                            );
                          }),
                      IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            var url = Uri.parse(widget.newLink);
                            launchURL(url);
                          }),
                      IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            Share.share(widget.newLink);
                          }),
                    ],
                  )
                : Row(),
            (widget.newLink != '')
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text('Copy'),
                      Text('Visit'),
                      Text('Share'),
                    ],
                  )
                : Row(),
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
