import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class SignInPhoneNumber extends StatefulWidget {
  const SignInPhoneNumber({Key? key}) : super(key: key);

  @override
  State<SignInPhoneNumber> createState() => _SignInPhoneNumberState();
}

class _SignInPhoneNumberState extends State<SignInPhoneNumber> {
  TextEditingController phoneController = TextEditingController();
  bool validate = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
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
            StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, snapshot) {
                  if (FirebaseAuth.instance.currentUser == null) {
                    return const Text("You haven't signed in yet");
                  } else {
                    if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                      return const Text("You haven't signed in yet");
                    } else {
                      return const Text('SIGNED IN');
                    }
                  }
                }),
            const SizedBox(height: 15),

            //* PHONE TEXTFIELD
            Container(
              margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                cursorColor: Colors.purple,
                onChanged: (value) {
                  setState(() {
                    validate = validateNumber(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter your phone number here',
                  hintText: '60123456789',
                  errorText:
                      validate ? null : "Please insert valid phone number",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),

            //* SIGN IN BUTTON
            SizedBox(
              width: 150,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.purple.shade900)),
                onPressed: () async {
                  validate = validateNumber(phoneController.text);
                  setState(() {});
                  // CODE HERE: Sign in with phone credential / Sign out from firebase

                  if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                    if (validate == true) {
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
                                await FirebaseAuth.instance.currentUser!
                                    .linkWithCredential(credential)
                                    .then((user) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  return user;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(
                                          'Successfully login using phone number')),
                                );
                              } on FirebaseAuthException catch (e) {
                                debugPrint(e.code);
                                if (e.code == "invalid-verification-code") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: Colors.red,
                                        content:
                                            Text('Wrong SMS code entered')),
                                  );
                                } else {
                                  await FirebaseAuth.instance
                                      .signInWithCredential(credential);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: Colors.purple,
                                        content: Text(
                                            'Successfully login using phone number')),
                                  );
                                  log(e.message.toString());
                                }
                              }
                            }
                          }),
                          codeAutoRetrievalTimeout: (verificationId) {});
                    }
                  } else {
                    PanaraConfirmDialog.show(
                      context,
                      title: "Logout ?",
                      message: 'Are you sure want to logout ?',
                      confirmButtonText: "Yes",
                      cancelButtonText: "No",
                      onTapCancel: () {
                        Navigator.pop(context);
                      },
                      onTapConfirm: () {
                        Navigator.pop(context);
                        FirebaseAuth.instance.signOut();
                        FirebaseAuth.instance.signInAnonymously();
                      },
                      panaraDialogType: PanaraDialogType.error,
                      barrierDismissible: false,
                    );
                  }
                },

                // CODE HERE: Change button text based on current user
                child: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.userChanges(),
                    builder: (context, snapshot) {
                      if (FirebaseAuth.instance.currentUser == null) {
                        return const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      } else {
                        if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                          return const Text("Login");
                        } else {
                          return const Text("Logout");
                        }
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
        backgroundColor: Colors.red, content: Text(message.toString())));
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
                    cursorColor: Colors.purple,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'SMS Code'),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, controller.text);
                    },
                    child: Text('Confirm',
                        style: TextStyle(color: Colors.purple.shade900)))
              ]);
        });
  }

  bool validateNumber(String number) {
    if (RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(number)) {
      return true;
    } else {
      return false;
    }
  }
}
