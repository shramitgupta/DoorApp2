import 'package:doorapp2/auth/user_auth/user_gmail_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DealerHomeScreen extends StatefulWidget {
  const DealerHomeScreen({super.key});

  @override
  State<DealerHomeScreen> createState() => _DealerHomeScreenState();
}

List button = [
  'Profile Screen',
  'Qr Scanner',
  'Total Points',
  'Leader Board',
  'Gift Details',
  'Redeem Status',
  'Points Used',
  'Contact Details',
  'Banking',
  'Upcomming Events',
  'LOGOUT'
];

class _DealerHomeScreenState extends State<DealerHomeScreen> {
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
                  CupertinoPageRoute(builder: (context) => UserGmailLogin()),
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
          'CARPENTER HOME',
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const UserProfileScreen(),
                            //   ),
                            // );
                          } else if (index == 1) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const UserQrScanner(),
                            //   ),
                            // );
                          } else if (index == 2) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const UserTotalPoints(),
                            //   ),
                            // );
                          } else if (index == 3) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const UserLeaderBoard(),
                            //   ),
                            // );
                          } else if (index == 4) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const UserGiftDetails(),
                            //   ),
                            // );
                          } else if (index == 5) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => UserRedeemStatus(),
                            //   ),
                            // );
                          } else if (index == 6) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const UserPointsUsed(),
                            //   ),
                            // );
                          } else if (index == 7) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         const UserContactDetails(),
                            //   ),
                            // );
                          } else if (index == 8) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const UserBanking(),
                            //   ),
                            // );
                          } else if (index == 9) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         const UserUpcommingEvent(),
                            //   ),
                            // );
                          } else if (index == 10) {
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
