import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  final String documentId;

  Profile({required this.documentId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        centerTitle: true,
        title: Text('Profile'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dealer')
            .doc(widget.documentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching data: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('Document does not exist'),
            );
          }

          final profileData = snapshot.data!.data() as Map<String, dynamic>;
          final profilePicUrl = profileData['sprofilepic'];

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(profilePicUrl),
                ),
                SizedBox(height: 20),
                ProfileInfoTile("Name", profileData['cname'].toString()),
                ProfileInfoTile(
                    "Company Name", profileData['companyname'].toString()),
                ProfileInfoTile("Email", profileData['email'].toString()),
                ProfileInfoTile("Phone No", profileData['cpno'].toString()),
                ProfileInfoTile("District", profileData['district'].toString()),
                ProfileInfoTile("State", profileData['state'].toString()),
                ProfileInfoTile("GST No", profileData['gstno'].toString()),
                ProfileInfoTile("PAN No", profileData['panno'].toString()),
                ProfileInfoTile(
                    "Aadhar No", profileData['aadharno'].toString()),
                ProfileInfoTile("Address", profileData['caddress'].toString()),
                ProfileInfoTile("Age", profileData['cage'].toString()),
                ProfileInfoTile("Anniversary Date",
                    profileData['canniversarydate'].toString()),
                ProfileInfoTile(
                    "Date of Birth", profileData['cdob'].toString()),
                ProfileInfoTile(
                    "Marital Status", profileData['cmaritalstatus'].toString()),
                ProfileInfoTile(
                    "Company No", profileData['companyno'].toString()),
                ProfileInfoTile("PIN", profileData['pin'].toString()),
                ProfileInfoTile(
                    "Total Orders", profileData['totalorders'].toString()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileInfoTile extends StatelessWidget {
  final String title;
  final dynamic data;

  ProfileInfoTile(this.title, this.data);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(data ?? "N/A"),
    );
  }
}
