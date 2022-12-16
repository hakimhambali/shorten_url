import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
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

  @override
  State<ViewQR> createState() => _ViewQRState();
}

class _ViewQRState extends State<ViewQR> {
  final controller = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Link QR Generator'),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final image = await controller.capture();
              if (image == null) return;
              await saveImage(image);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Column(
              children: [
                Screenshot(
                  controller: controller,
                  child: Center(
                    child: Container(
                      width: 340,
                      color: Colors.white,
                      padding: const EdgeInsets.all(10.0),
                      child: QRCode(
                        qrSize: 320,
                        qrData: widget.originalLink,
                      ),
                    ),
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

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'generate_qr_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          backgroundColor: Colors.green,
          content: Text('QR code has been downloaded succesfully')),
    );
    final path = result['filePath'].split('file://')[1];
    OpenFilex.open(path);
    // openFile(result: path);
    return result['filePath'];
  }

  // Future<void> openFile({required String result}) async {
  //   final result2 = await OpenFilex.open(result);
  //   debugPrint(result);
  //   // debugPrint(result2.type.toString());
  //   if (result2.type.toString() == "ResultType.fileNotFound") {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           backgroundColor: Colors.red,
  //           content: Text('Image maybe was deleted in your phone')),
  //     );
  //   }
  // }
}
