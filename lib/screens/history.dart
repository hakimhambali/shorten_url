import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: const Center(
        child: Text('View QR link'),
      ),
    );
  }

  // Future init() async {
  //   userhistory = await SharedPreferences.getInstance();

  //   String? date = preferences.getString("date");
  //   if (date == null) return;

  //   setState(() => this.date = date);
  // }
}
