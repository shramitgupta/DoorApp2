import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorapp2/auth/admin_auth/admin_gmail_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminSignIn extends StatefulWidget {
  const AdminSignIn({Key? key});

  @override
  State<AdminSignIn> createState() => _AdminSignInState();
}

class _AdminSignInState extends State<AdminSignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String statusMessage = ''; // To show success/error message

  void signUp() async {
    setState(() {
      isLoading = true;
      statusMessage = '';
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == '' || password == '') {
      setState(() {
        isLoading = false;
        statusMessage = 'Fill all fields.';
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Add user's email to Firestore collection
        await FirebaseFirestore.instance.collection('admin').add({
          'email': email,
        });

        setState(() {
          isLoading = false;
          statusMessage = 'Successfully signed up!';
        });

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AdminLogin()));
      }
    } on FirebaseAuthException catch (ex) {
      setState(() {
        isLoading = false;
        if (ex.code == 'email-already-in-use') {
          statusMessage = 'Email already in use.';
        } else {
          statusMessage = 'An error occurred. Please try again later.';
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
              "Admin\nSign Up",
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
                onPressed: isLoading ? null : signUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  backgroundColor:
                      isLoading ? Colors.grey : Colors.brown.shade900,
                  shape: StadiumBorder(),
                ),
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
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
            if (statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  statusMessage,
                  style: TextStyle(
                    color: statusMessage.contains('Success')
                        ? Colors.green
                        : Colors.red,
                    fontSize: 16,
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
