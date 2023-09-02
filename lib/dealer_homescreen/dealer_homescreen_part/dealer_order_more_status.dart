import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class DealerMoreStatus extends StatefulWidget {
  final DocumentSnapshot document;

  const DealerMoreStatus({Key? key, required this.document}) : super(key: key);

  @override
  State<DealerMoreStatus> createState() => _DealerMoreStatusState();
}

class _DealerMoreStatusState extends State<DealerMoreStatus> {
  bool showBillImage = false;
  bool showBiltyImage = false;

  @override
  Widget build(BuildContext context) {
    String status = widget.document['status'];

    // Define a list of status items with their names, approval states, and icons
    List<StatusItem> statusItems = [
      StatusItem('Not Approved', false, Icons.error),
      StatusItem('Approved', true, Icons.check_circle),
      StatusItem('Sizing Done', true, Icons.done),
      StatusItem('Posting Done', true, Icons.check_circle_outline),
      StatusItem('Packing Done', true, Icons.check_circle_outline),
      StatusItem('Dispatched', true, Icons.local_shipping),
      StatusItem('Recieved', true, Icons.done_all),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Status Details'),
        backgroundColor: Colors.green, // Customize the app bar color
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                statusItems.firstWhere((item) => item.name == status).icon,
                size: 80,
                color:
                    statusItems.firstWhere((item) => item.name == status).color,
              ),
              SizedBox(height: 20),
              Text(
                'Order Status:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              // Build the status list with a custom design
              StatusList(
                statusItems: statusItems,
                currentStatus: status,
              ),
              if (status == 'Dispatched')
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showBillImage = true;
                    });
                  },
                  child: Text('Show Bill Image'),
                ),
              if (showBillImage)
                buildImage(widget.document['bill'], 'Bill Image'),
              if (status == 'Dispatched')
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showBiltyImage = true;
                    });
                  },
                  child: Text('Show Bilty Image'),
                ),
              if (showBiltyImage)
                buildImage(widget.document['bilty'], 'Bilty Image'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImage(String? imageUrl, String imageLabel) {
    if (imageUrl != null) {
      return GestureDetector(
        onTap: () {
          showImageDialog(imageUrl, imageLabel);
        },
        child: Column(
          children: [
            Text(imageLabel),
            Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            ElevatedButton(
              onPressed: () {
                shareImage(imageUrl, imageLabel);
              },
              child: Text('Share $imageLabel'),
            ),
          ],
        ),
      );
    } else {
      // Handle the case where imageUrl is null or empty
      return Text('No $imageLabel available.');
    }
  }

  void showImageDialog(String imageUrl, String imageLabel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.network(imageUrl),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void shareImage(String? imageUrl, String imageLabel) {
    if (imageUrl != null) {
      Share.share(
        imageUrl,
        subject: 'Order $imageLabel Image',
        sharePositionOrigin: Rect.fromCenter(
          center: Offset(0, 0),
          width: 100,
          height: 100,
        ),
      );
    } else {
      print('Image URL is null or empty.');
    }
  }
}

class StatusItem {
  final String name;
  final bool approved;
  final IconData icon;
  final Color color;

  StatusItem(this.name, this.approved, this.icon)
      : color = approved ? Colors.green : Colors.red;
}

class StatusList extends StatelessWidget {
  final List<StatusItem> statusItems;
  final String currentStatus;

  StatusList({required this.statusItems, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: statusItems.map((statusItem) {
        bool isActive = statusItem.name == currentStatus;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? statusItem.color : Colors.grey,
                ),
                child: Icon(
                  statusItem.icon,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Text(
                statusItem.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActive ? statusItem.color : Colors.black,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
