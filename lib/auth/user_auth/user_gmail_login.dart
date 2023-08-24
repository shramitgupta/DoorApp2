import 'package:doorapp2/user_signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserGmailLogin extends StatefulWidget {
  UserGmailLogin({Key? key});

  @override
  State<UserGmailLogin> createState() => _UserGmailLoginState();
}

class _UserGmailLoginState extends State<UserGmailLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fill all Fields ')),
      );
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if (userCredential.user != null) {
          Navigator.popUntil(context, (route) => route.isFirst);
          // Navigator.pushReplacement(context,
          //     CupertinoPageRoute(builder: (context) => const UserHomeScreen()));
        }
      } on FirebaseAuthException catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$ex')),
        );
      }
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
              "User\nLogin",
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
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter Password',
                labelStyle: TextStyle(color: Colors.brown.shade900),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 3,
                    color: Colors.brown.shade900,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  backgroundColor: Colors.brown.shade900,
                  shape: StadiumBorder(),
                ),
                child: Text(
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
            Center(
              child: TextButton(
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown.shade900,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserSignUp()),
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
