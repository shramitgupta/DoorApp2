import 'package:doorapp2/auth/admin_auth/admin_signup.dart';
import 'package:flutter/material.dart';

class AdminPassword extends StatefulWidget {
  @override
  _AdminPasswordState createState() => _AdminPasswordState();
}

class _AdminPasswordState extends State<AdminPassword> {
  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  final String correctPassword = '123456';
  String message = '';

  void checkPassword() {
    String enteredPassword =
        controllers.map((controller) => controller.text).join();

    if (enteredPassword == correctPassword) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AdminSignIn()), // Navigate to the other page
      );
    } else {
      setState(() {
        message = 'Wrong Password';
      });
    }
  }

  @override
  void dispose() {
    controllers.forEach((controller) => controller.dispose());
    focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      controllers[i].addListener(() {
        if (controllers[i].text.length == 1) {
          if (i < 5) {
            FocusScope.of(context).requestFocus(focusNodes[i + 1]);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double boxSize = MediaQuery.of(context).size.width * 0.12;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        title: Text('Admin Password'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: boxSize,
                      height: boxSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextFormField(
                        controller: controllers[index],
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        maxLength: 1,
                        style: TextStyle(
                            fontSize: boxSize * 0.35,
                            fontWeight: FontWeight.bold),
                        focusNode: focusNodes[index],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: checkPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  backgroundColor: Colors.brown.shade900,
                  shape: StadiumBorder(),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: message == 'Wrong Password' ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
