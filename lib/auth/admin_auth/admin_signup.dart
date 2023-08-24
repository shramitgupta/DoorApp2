import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminSignIn extends StatefulWidget {
  const AdminSignIn({Key? key});

  @override
  State<AdminSignIn> createState() => _AdminSignInState();
}

class _AdminSignInState extends State<AdminSignIn> {
  final TextEditingController phonenoController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void startPhoneNumberVerification(BuildContext context) async {
    String phonenoString = phonenoController.text;
    String phone = "+91" + phonenoString.trim();

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        codeSent: (verificationId, resendToken) {
          // Navigator.push(
          //   context,
          //   CupertinoPageRoute(
          //     builder: (context) => AdminOtpSignup(
          //       verificationId: verificationId,
          //       onVerificationCompleted: (credential) {
          //         signUpUser(context, phonenoString);
          //       },
          //     ),
          //   ),
          // );
        },
        verificationCompleted:
            (credential) {}, // Empty function as a placeholder
        verificationFailed: (ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone number verification failed: $ex')),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
        timeout: Duration(seconds: 30),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while verifying phone number: $e')),
      );
    }
  }

  void signUpUser(BuildContext context, String phonenoString) async {
    int phoneno = int.parse(phonenoString);

    phonenoController.clear();

    try {
      //final UserCredential userCredential = await _auth.signInAnonymously();

      //String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance
          .collection('Admin')
          .doc()
          .set({'contactNumber': phoneno});
      log(phoneno.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: const Color.fromARGB(255, 70, 63, 60),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Container(
            color: const Color.fromARGB(255, 195, 162, 132),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenHeight * 0.1,
                ),
                const Text(
                  " Admin",
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                ),
                const Text(
                  " Sign Up",
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: phonenoController,
                    cursorColor: const Color.fromARGB(255, 70, 63, 60),
                    decoration: InputDecoration(
                      labelText: 'Enter Phone No',
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 70, 63, 60)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            const BorderSide(width: 3, color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 3,
                          color: Color.fromARGB(255, 70, 63, 60),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        startPhoneNumberVerification(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 7.0),
                        backgroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Sign in",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.yellow,
                        ),
                      ),
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => AdminPhoneNoLogin()),
                        // );
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Login as Carpenter'),
                    TextButton(
                      child: const Text(
                        'Carpenter',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.yellow,
                        ),
                      ),
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => UserPhoneNoLogin()),
                        // );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
