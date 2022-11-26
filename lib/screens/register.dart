import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shorten_url/screens/forgot_password.dart';
import 'package:shorten_url/screens/login.dart';
import 'package:shorten_url/screens/signingoogle.dart';
import 'package:shorten_url/screens/signinphonenumber.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool checkEmail = true;
  bool checkPassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'QR & URL Master',
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
                      return Text('SIGNED IN ${snapshot.data?.email}');
                    }
                  }
                }),
            Container(
              margin: const EdgeInsets.fromLTRB(30, 25, 30, 10),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: TextFormField(
                controller: emailController,
                cursorColor: Colors.orange,
                onChanged: (value) {
                  setState(() {
                    checkEmail = validateEmail(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter your email here',
                  hintText: 'ahmadalbab99@gmail.com',
                  errorText: checkEmail ? null : "Please insert valid email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(30, 10, 30, 15),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              // decoration: BoxDecoration(
              //     color: Colors.white, borderRadius: BorderRadius.circular(15)),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: TextFormField(
                controller: passwordController,
                cursorColor: Colors.orange,
                onChanged: (value) {
                  setState(() {
                    checkPassword = validatePassword(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter your password here',
                  hintText: '*********',
                  errorText: checkPassword
                      ? null
                      // : "Password should contain at least one upper case, one lower case, one digit, one Special character and at least 8 characters in length",
                      : "Please insert valid password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, right: 20),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPassword()));
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Colors.orange.shade900)),
                      onPressed: () async {
                        checkEmail = validateEmail(emailController.text);
                        checkPassword =
                            validatePassword(passwordController.text);
                        setState(() {});

                        try {
                          if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                            var credential = EmailAuthProvider.credential(
                                email: emailController.text,
                                password: passwordController.text);
                            await FirebaseAuth.instance.currentUser!
                                .linkWithCredential(credential)
                                .then((user) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                        'Successfully register using email')),
                              );
                              Navigator.pop(context);
                              return user;
                            });
                          } else {
                            // FirebaseAuth.instance.signOut();
                            // await FirebaseAuth.instance
                            //     .signOut()
                            //     .then((value) async {
                            //   await FirebaseAuth.instance.signInAnonymously();
                            // });
                            await FirebaseAuth.instance.signOut();
                            await FirebaseAuth.instance.signInAnonymously();
                          }
                        } on FirebaseAuthException catch (e) {
                          showNotification(context, e.message.toString());
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('Invalid Register')),
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
                              if (FirebaseAuth
                                  .instance.currentUser!.isAnonymous) {
                                return const Text("Register");
                              } else {
                                return const Text("Logout");
                              }
                            }
                          })),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        // margin: const EdgeInsets.fromLTRB(0, 10, 0, 40),
                        margin: const EdgeInsets.only(top: 10, bottom: 20),
                        // alignment: Alignment.center,
                        child: const Text("Already have an account ?  ")),
                    Container(
                      // margin: const EdgeInsets.fromLTRB(0, 10, 0, 40),
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      // alignment: Alignment.center,
                      child: GestureDetector(
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()));
                        },
                      ),
                    ),
                  ],
                ),
                const Text("OR"),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black)),
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInGoogle()));
                    },
                    child: const Text('Sign In With Google Account'),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black)),
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInPhoneNumber()));
                    },
                    child: const Text('Sign In With Phone Number'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.orange.shade900,
        content: Text(message.toString())));
  }

  bool validateEmail(String email) {
    if (RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email)) {
      return true;
    } else {
      return false;
    }
  }

  bool validatePassword(String password) {
    if (RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(password)) {
      return true;
    } else {
      return false;
    }
  }
}
