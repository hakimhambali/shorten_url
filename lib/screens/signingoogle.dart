import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class SignInGoogle extends StatelessWidget {
  const SignInGoogle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SIGN IN WITH GOOGLE ACCOUNT',
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, snapshot) {
                  if (FirebaseAuth.instance.currentUser == null) {
                    return const Text("You haven't signed in yet");
                  } else {
                    if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                      return const Text("You haven't signed in yet");
                    } else {
                      return Text(
                        'Signed in as ${FirebaseAuth.instance.currentUser!.displayName} (${FirebaseAuth.instance.currentUser!.email})',
                        textAlign: TextAlign.center,
                      );
                    }
                  }
                }),
            const SizedBox(height: 15),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.purple.shade900)),
                  onPressed: () async {
                    if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                      try {
                        GoogleSignIn _googleSignIn = GoogleSignIn();
                        await _googleSignIn.disconnect();
                      } catch (e) {
                        print(e);
                      }

                      GoogleSignInAccount? account =
                          await GoogleSignIn().signIn();
                      try {
                        if (account != null) {
                          GoogleSignInAuthentication auth =
                              await account.authentication;
                          var credential = GoogleAuthProvider.credential(
                              accessToken: auth.accessToken,
                              idToken: auth.idToken);
                          await FirebaseAuth.instance.currentUser!
                              .linkWithCredential(credential)
                              .then((user) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text(
                                      'Successfully login using google account')),
                            );
                            Navigator.pop(context);
                            Navigator.pop(context);
                            return user;
                          });
                        }
                      } on FirebaseAuthException catch (e) {
                        // if (e.code == "credential-already-in-use") {
                        if (account != null) {
                          GoogleSignInAuthentication auth =
                              await account.authentication;
                          OAuthCredential credential =
                              GoogleAuthProvider.credential(
                                  accessToken: auth.accessToken,
                                  idToken: auth.idToken);
                          await FirebaseAuth.instance
                              .signInWithCredential(credential)
                              .then((user) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text(
                                      'Successfully login using google account')),
                            );
                            Navigator.pop(context);
                            Navigator.pop(context);
                            return user;
                          });
                        }
                        // }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('Invalid Login')),
                          );
                          log(e.message.toString());
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('Invalid Login')),
                        );
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
                      })),
            )
          ],
        ),
      ),
    );
  }
}
