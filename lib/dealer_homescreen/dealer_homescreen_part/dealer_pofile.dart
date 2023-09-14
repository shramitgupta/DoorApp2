import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DealerProfile extends StatefulWidget {
  const DealerProfile({Key? key}) : super(key: key);

  @override
  State<DealerProfile> createState() => _DealerProfileState();
}

class _DealerProfileState extends State<DealerProfile> {
  String? documentId;
  CollectionReference customers =
      FirebaseFirestore.instance.collection('dealer');

  @override
  void initState() {
    super.initState();
    // Listen to authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          documentId = user.uid;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder<DocumentSnapshot>(
      future: customers.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: Colors.brown.shade900,
              title: const Text(
                'PROFILE',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text('Something went wrong')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text('No Data')),
            body: Center(child: Text('Document does not exist')),
          );
        }

        // Extract data from the document snapshot
        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.brown.shade900,
            title: const Text(
              'PROFILE',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Hero(
                    tag: 'profileImage',
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(width: 10, color: Colors.brown.shade900),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.shade900,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(data["sprofilepic"]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 200,
                      width: 200,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                buildProfileDetail("Company Name", data["cname"]),
                buildProfileDetail("Age", data["cage"].toString()),
                buildProfileDetail("E-Mail", data["email"].toString()),
                buildProfileDetail("Phone No", data["cpno"].toString()),
                buildProfileDetail("Address", data["caddress"].toString()),
                buildProfileDetail("Date Of Birth", data["cdob"].toString()),
                buildProfileDetail(
                    "Marital Status", data["cmaritalstatus"].toString()),
                buildProfileDetail(
                    "Anniversary Date", data["canniversarydate"].toString()),
                buildProfileDetail("Aadhar No", data["aadharno"].toString()),
                buildProfileDetail(
                    "Company Name", data["companyname"].toString()),
                buildProfileDetail("District", data["district"].toString()),
                buildProfileDetail("State", data["state"].toString()),
                buildProfileDetail("Pan No", data["panno"].toString()),
                buildProfileDetail("Pincode", data["pin"].toString()),
                buildProfileDetail("GST No", data["gstno"].toString()),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'images/logo.png',
                    height: screenHeight * 0.22,
                    //width: 30,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to build profile detail
  Widget buildProfileDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
