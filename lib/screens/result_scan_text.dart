import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

class ResultScanText extends StatefulWidget {
  final String result;
  final Function(bool) onPop;
  const ResultScanText({
    Key? key,
    required this.result,
    required this.onPop,
  }) : super(key: key);

  @override
  State<ResultScanText> createState() => _ResultScanTextState();
}

class _ResultScanTextState extends State<ResultScanText> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        widget.onPop(true);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.purple.shade50,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Text Scanner'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Text(
                widget.result,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )),
              const SizedBox(
                height: 30,
              ),
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text('Copy'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
