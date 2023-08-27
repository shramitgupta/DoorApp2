import 'package:doorapp2/admin_homescreen/admin_homescreen_part/admin_dealer_register.dart';
import 'package:doorapp2/auth/admin_auth/admin_gmail_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

List button = [
  'Dealer Register',
  'Qr Generator',
  'Carpenter Details',
  'Leader Board',
  'Gift Request',
  'What to Send',
  'Total Gifts Sent',
  'Add Gifts',
  'Delete Carpenter',
  'LOGOUT'
];

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  void logOut() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log Out"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Log Out"),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(builder: (context) => AdminLogin()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        title: const Text(
          'ADMIN HOME',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: button.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          if (index == 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DealerRegister(),
                              ),
                            );
                          } else if (index == 1) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => QrGenerator(),
                            //   ),
                            // );
                          } else if (index == 2) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const CarpenterDetails(),
                            //   ),
                            // );
                          } else if (index == 3) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         const CarpenterLeaderBoard(),
                            //   ),
                            // );
                          } else if (index == 4) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         const CarpenterGiftRequest(),
                            //   ),
                            // );
                          } else if (index == 5) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         const CarpenterWhatToSend(),
                            //   ),
                            // );
                          } else if (index == 6) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         const CarpenterTotalGifts(),
                            //   ),
                            // );
                          } else if (index == 7) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const CarpenterAddGifts(),
                            //   ),
                            // );
                          } else if (index == 8) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const CarpenterDelete(),
                            //   ),
                            // );
                          } else if (index == 9) {
                            logOut();
                          }
                        },
                        title: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          child: Container(
                            color: Colors.brown.shade900,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  button[index],
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'images/logo.png',
                height: screenHeight * 0.12,
                //width: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
