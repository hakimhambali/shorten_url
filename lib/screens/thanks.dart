import 'package:flutter/material.dart';

class Thanks extends StatefulWidget {
  const Thanks({super.key});

  @override
  State<Thanks> createState() => _ThanksState();
}

class _ThanksState extends State<Thanks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thank you'),
      ),
      body: Container(
        padding: const EdgeInsets.all(80.100),
        child: Column(
          children: const [
            Text(
              'Thank you for your feedback, we will improve according to your feedback from time to time. May your day be filled with good thoughts, kind people and happy moments',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20)),
          ],
        ),
      ),
    );
  }
}
