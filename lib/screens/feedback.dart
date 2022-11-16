import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shorten_url/screens/thanks.dart';

class Improvement extends StatefulWidget {
  const Improvement({Key? key}) : super(key: key);

  @override
  State<Improvement> createState() => _ImprovementState();
}

class _ImprovementState extends State<Improvement> {
  final controller = TextEditingController();
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
              'Got any problems ? or is there any features that you want to see in the future ? In order to serve the best for you, We would love to hear your feedback !',
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
                    if (controller.text.isNotEmpty) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                  'Are you sure want to submit your feedback ?',
                                  textAlign: TextAlign.center),
                              content: SizedBox(
                                height: 80,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 25.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: const Icon(Icons.close),
                                              label: const Text('No')),
                                          ElevatedButton.icon(
                                              onPressed: () {
                                                submitFeedback(
                                                    feedback: controller.text,
                                                    date: DateTime.now()
                                                        .toString());
                                                Navigator.pop(context);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Thanks()));
                                              },
                                              icon: const Icon(Icons.check),
                                              label: const Text('Yes'))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                                'Please enter your feedback before clicking submit')),
                      );
                    }
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
