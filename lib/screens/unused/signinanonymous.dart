import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInAnonymous extends StatelessWidget {
  const SignInAnonymous({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //* TITLE
            Text(
              'SIGN IN ANONYMOUSLY',
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            //* SIGN IN STATUS
            // CODE HERE: Change status based on current user
            StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text('SIGNED IN: ${snapshot.data?.uid}');
                  } else {
                    return const Text("You haven't signed in yet");
                  }
                }),
            const SizedBox(height: 15),

            //* SIGN IN BUTTON
            SizedBox(
              width: 150,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.lightBlue.shade900)),
                onPressed: () async {
                  // CODE HERE: Sign in anonymously / Sign out from firebase
                  if (FirebaseAuth.instance.currentUser != null) {
                    FirebaseAuth.instance.signOut();
                  } else {
                    FirebaseAuth.instance.signInAnonymously();
                  }
                },
                // CODE HERE: Change button text based on current user
                child: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.userChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return const Text("Sign Out");
                      } else {
                        return const Text("Sign In");
                      }
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
