import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
            //* TITLE
            Text(
              'SIGN IN WITH GOOGLE ACCOUNT',
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            //* SIGN IN STATUS
            // CODE HERE: Change status based on current user
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

            //* SIGN IN BUTTON
            SizedBox(
              width: 150,
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.purple.shade900)),
                  onPressed: () async {
                    // CODE HERE: Sign in with Google Credential / Sign out from firebase & Google
                    if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                      GoogleSignIn _googleSignIn = GoogleSignIn();
                      await _googleSignIn.disconnect();
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
                            return user;
                          });
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
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
                              .signInWithCredential(credential);
                          Navigator.pop(context);
                          Navigator.pop(context);
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
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Are you sure want to logout ?',
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
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              // icon: const Icon(Icons.close),
                                              child: const Text('No')),
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                FirebaseAuth.instance.signOut();
                                                // GoogleSignIn().signOut();
                                                FirebaseAuth.instance
                                                    .signInAnonymously();
                                              },
                                              // icon: const Icon(Icons.check),
                                              child: const Text('Yes'))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            // GoogleSignIn().signOut();
                            // await FirebaseAuth.instance.signInAnonymously();
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => const Register()));
                          });
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
                      })),
            )
          ],
        ),
      ),
    );
  }
}
