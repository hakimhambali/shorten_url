import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shorten_url/screens/congrats.dart';

class Improvement extends StatefulWidget {
  const Improvement({Key? key}) : super(key: key);

  @override
  State<Improvement> createState() => _ImprovementState();
}

class _ImprovementState extends State<Improvement> {
  final controller = TextEditingController();
  DateTime now = DateTime.now();
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
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20)),
            TextFormField(
              // validator: (String? input){

              // },
              controller: controller,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 120.0, horizontal: 10.0),
                  label: const Center(
                    child: Text("Enter your Feedback here"),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(
              height: 30,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    submitFeedback(
                        feedback: controller.text, date: now.toString());
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Congrats()));
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

  Future submitFeedback(
      {required String feedback, required String date}) async {
    final feedbackUser =
        FirebaseFirestore.instance.collection('feedback').doc();
    final json = {
      'feedback': feedback,
      'date': date,
      'type': "Feedback",
      'userID': FirebaseAuth.instance.currentUser!.uid.toString()
    };
    await feedbackUser.set(json);
  }
}
