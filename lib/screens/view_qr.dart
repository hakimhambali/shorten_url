import 'package:flutter/material.dart';
import '../widgets/qr_code_widget.dart';

class ViewQR extends StatefulWidget {

   String url;
   ViewQR(this.url, {Key? key}) : super(key: key);

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
      body:  Center(
        // Add this QRCode widget in place of the Container
        child: QRCode(
          qrSize: 320,
          qrData: widget.url,
        ),
      ),
    );
  }
}
