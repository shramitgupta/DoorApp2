import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminGmailLogin extends StatefulWidget {
  AdminGmailLogin({Key? key});

  @override
  State<AdminGmailLogin> createState() => _AdminGmailLoginState();
}

class _AdminGmailLoginState extends State<AdminGmailLogin> {
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
          // Navigator.pushReplacement(
          //     context,
          //     CupertinoPageRoute(
          //         builder: (context) => const AdminHomeScreen()));
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
    //double screenWidth = MediaQuery.of(context).size.width;
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
                  " Login",
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: screenHeight * 0.1,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: emailController,
                    // style: const TextStyle(height: 30),
                    cursorColor: const Color.fromARGB(255, 70, 63, 60),
                    decoration: InputDecoration(
                      labelText: 'Enter Gmail ',
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: passwordController,
                    // style: const TextStyle(height: 30),
                    cursorColor: const Color.fromARGB(255, 70, 63, 60),
                    decoration: InputDecoration(
                      labelText: 'Enter Password',
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
                        login();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const AdminOtp()),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 7.0),
                        backgroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Login",
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
                    const Text("Login with Phone no?"),
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
                    const Text("Don't have account?"),
                    TextButton(
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.yellow,
                        ),
                      ),
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const AdminSignIn()),
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
