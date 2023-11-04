import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  final String documentId;

  Profile({required this.documentId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<void> deleteDealer() async {
    final confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Dealer'),
          content: Text('Are you sure you want to delete this dealer?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel delete
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm delete
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        // Delete from Firestore collection 'dealer'
        await FirebaseFirestore.instance
            .collection('dealer')
            .doc(widget.documentId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Dealer deleted successfully.'),
        ));

        // Navigate back to the previous screen after deletion
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error deleting dealer: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        centerTitle: true,
        title: Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: deleteDealer,
          ),
        ],
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
