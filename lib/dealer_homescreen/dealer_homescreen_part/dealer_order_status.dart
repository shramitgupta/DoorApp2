import 'package:doorapp2/dealer_homescreen/dealer_homescreen_part/dealer_order_more_status.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import your DealerMoreStatus file

class DealerOrderStatus extends StatefulWidget {
  const DealerOrderStatus({Key? key});

  @override
  State<DealerOrderStatus> createState() => _DealerOrderStatusState();
}

class _DealerOrderStatusState extends State<DealerOrderStatus> {
  String? userId;

  @override
  void initState() {
    super.initState();
    getUserID();
  }

  void getUserID() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        title: const Text(
          'Order Status',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("userId", isEqualTo: userId)
            .orderBy("ordertime", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.active) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                Timestamp timestamp = document['ordertime'] as Timestamp;
                DateTime orderTime = timestamp.toDate();

                return GestureDetector(
                  onTap: () => _showItemDetails(context, document),
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      title: Text(
                        "Company Name: ${document['companyName']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            "Order Date: ${_formatDate(orderTime)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Order Time: ${_formatTime(orderTime)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Order Status: ${document['status']}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Text('View Attachment'),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  String _formatDate(DateTime time) {
    return "${time.day}/${time.month}/${time.year}";
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}";
  }

  void _showImageDialog(BuildContext context, String? imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: PhotoView(
                imageProvider: NetworkImage(imageUrl ?? ''),
                backgroundDecoration: BoxDecoration(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showItemDetails(BuildContext context, DocumentSnapshot document) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => DealerMoreStatus(
                document: document,
              )),
    );
  }
}
