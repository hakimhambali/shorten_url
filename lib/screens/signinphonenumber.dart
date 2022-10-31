import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPhoneNumber extends StatelessWidget {
  const SignInPhoneNumber({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController phoneController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //* TITLE
            Text(
              'SIGN IN WITH PHONE',
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const Text("Enter with country code (eg:60123456789)"),

            // //* SIGN IN STATUS
            // // CODE HERE: Change status based on current user
            // StreamBuilder<User?>(
            //     stream: FirebaseAuth.instance.userChanges(),
            //     builder: (context, snapshot) {
            //       if (FirebaseAuth.instance.currentUser!.isAnonymous) {
            //         return const Text("Sign Out");
            //       } else {
            //         return const Text("You haven't signed in yet");
            //       }
            //     }),
            const SizedBox(height: 15),

            //* PHONE TEXTFIELD
            Container(
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 15),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                cursorColor: Colors.green,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter with country code (eg:60123456789)'),
              ),
            ),

            //* SIGN IN BUTTON
            SizedBox(
              width: 150,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.green.shade900)),
                onPressed: () async {
                  // CODE HERE: Sign in with phone credential / Sign out from firebase
                  if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                    await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: '+${phoneController.text}',
                        verificationCompleted: (credential) async {
                          await FirebaseAuth.instance
                              .signInWithCredential(credential);
                        },
                        verificationFailed: (exception) {
                          showNotification(
                              context, exception.message.toString());
                        },
                        codeSent: ((verificationId, resendCode) async {
                          String? smsCode = await askingSMSCode(context);
                          if (smsCode != null) {
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                                    verificationId: verificationId,
                                    smsCode: smsCode);
                            try {
                              FirebaseAuth.instance
                                  .signInWithCredential(credential);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            } on FirebaseAuthException catch (e) {
                              log(e.message.toString());
                            }
                          }
                        }),
                        codeAutoRetrievalTimeout: (verificationId) {});
                  } else {
                    FirebaseAuth.instance.signOut();
                    await FirebaseAuth.instance.signInAnonymously();
                  }
                },
                // CODE HERE: Change button text based on current user
                child: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.userChanges(),
                    builder: (context, snapshot) {
                      if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                        return const Text("Login");
                      } else {
                        return const Text("Logout");
                      }
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green.shade900,
        content: Text(message.toString())));
  }

  Future<String?> askingSMSCode(BuildContext context) async {
    return await showDialog<String>(
        context: context,
        builder: (_) {
          TextEditingController controller = TextEditingController();

          return SimpleDialog(
              title: const Text('Please enter the SMS code sent to you'),
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(30, 0, 30, 15),
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  color: const Color.fromARGB(255, 240, 240, 240),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.green,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'SMS Code'),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, controller.text);
                    },
                    child: Text('Confirm',
                        style: TextStyle(color: Colors.green.shade900)))
              ]);
        });
  }
}
