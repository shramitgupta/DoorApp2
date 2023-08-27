import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:doorapp2/auth/admin_auth/admin_gmail_login.dart';
import 'package:doorapp2/dealer_homescreen/dealer_homescreen.dart';

class UserGmailLogin extends StatefulWidget {
  const UserGmailLogin({Key? key});

  @override
  State<UserGmailLogin> createState() => _UserGmailLoginState();
}

class _UserGmailLoginState extends State<UserGmailLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorText = '';
  bool passwordVisible = false;

  Future<bool> verifyDealerEmail(String enteredEmail) async {
    try {
      final dealerSnapshot = await FirebaseFirestore.instance
          .collection('dealers')
          .where('email', isEqualTo: enteredEmail)
          .get();
      return dealerSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void login() async {
    setState(() {
      isLoading = true;
      errorText = '';
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      setState(() {
        isLoading = false;
        errorText = 'Please fill all fields.';
      });
      return;
    }

    bool isDealerEmail = await verifyDealerEmail(email);
    if (!isDealerEmail) {
      setState(() {
        isLoading = false;
        errorText = 'User not found.';
      });
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => const DealerHomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (ex) {
      setState(() {
        isLoading = false;
        if (ex.code == 'user-not-found') {
          errorText = 'User not found.';
        } else if (ex.code == 'wrong-password') {
          errorText = 'Wrong password.';
        } else {
          errorText = 'An error occurred. Please try again later.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.1),
            Text(
              "Dealer\nLogin",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade900,
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
            TextFormField(
              controller: emailController,
              cursorColor: Colors.brown.shade900,
              decoration: InputDecoration(
                labelText: 'Enter Gmail',
                labelStyle: TextStyle(color: Colors.brown.shade900),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 3,
                    color: Colors.brown.shade900,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              cursorColor: Colors.brown.shade900,
              obscureText: !passwordVisible,
              decoration: InputDecoration(
                labelText: 'Enter Password',
                labelStyle: TextStyle(color: Colors.brown.shade900),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 3,
                    color: Colors.brown.shade900,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.brown.shade900,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  backgroundColor: Colors.brown.shade900,
                  shape: StadiumBorder(),
                ),
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 16),
            if (errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  errorText,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                child: Text(
                  "Login as Admin",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown.shade900,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminLogin()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
