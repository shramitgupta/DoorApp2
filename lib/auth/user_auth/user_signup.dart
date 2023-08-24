import 'package:doorapp2/user_gmail_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserSignUp extends StatefulWidget {
  const UserSignUp({Key? key});

  @override
  State<UserSignUp> createState() => _UserSignUpState();
}

class _UserSignUpState extends State<UserSignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fill all Fields')),
      );
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        if (userCredential.user != null) {
          // Navigate to the next screen
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextScreen()));
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
              "User\nSign Up",
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
                labelText: 'Enter E-Mail',
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
                onPressed: signUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  backgroundColor: Colors.brown.shade900,
                  shape: StadiumBorder(),
                ),
                child: Text(
                  "Sign Up",
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
                  "Already have an account? Log In",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown.shade900,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserGmailLogin()),
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
