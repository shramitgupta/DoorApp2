import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class DealerMoreStatus extends StatefulWidget {
  final DocumentSnapshot document;

  const DealerMoreStatus({Key? key, required this.document}) : super(key: key);

  @override
  State<DealerMoreStatus> createState() => _DealerMoreStatusState();
}

class _DealerMoreStatusState extends State<DealerMoreStatus> {
  String status = '';
  bool showBillImage = false;
  bool showBiltyImage = false;

  @override
  void initState() {
    super.initState();
    status = widget.document['status'];
  }

  @override
  Widget build(BuildContext context) {
    List<StatusItem> statusItems = [
      StatusItem('Not Approved', false, Icons.error),
      StatusItem('Approved', true, Icons.check_circle),
      StatusItem('Sizing Done', true, Icons.done),
      StatusItem('Posting Done', true, Icons.check_circle_outline),
      StatusItem('Packing Done', true, Icons.check_circle_outline),
      StatusItem('Dispatched', true, Icons.local_shipping),
      StatusItem('Received', true, Icons.done_all),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Status Details'),
        backgroundColor: Colors.green,
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
              StatusList(
                statusItems: statusItems,
                currentStatus: status,
              ),
              if (status == 'Dispatched') ...[
                ElevatedButton(
                  onPressed: () {
                    showConfirmationDialog('Received');
                  },
                  child: Text('Mark as Received'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showBillImage = true;
                    });
                  },
                  child: Text('Show Bill Image'),
                ),
              ],
              if (showBillImage) ...[
                buildImage(context, widget.document['bill'], 'Bill Image'),
                ElevatedButton(
                  onPressed: () {
                    downloadImage(
                        context, widget.document['bill'], 'Bill Image');
                  },
                  child: Text('Download Bill Image'),
                ),
              ],
              if (status == 'Dispatched') ...[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showBiltyImage = true;
                    });
                  },
                  child: Text('Show Bilty Image'),
                ),
              ],
              if (showBiltyImage) ...[
                buildImage(context, widget.document['bilty'], 'Bilty Image'),
                ElevatedButton(
                  onPressed: () {
                    downloadImage(
                        context, widget.document['bilty'], 'Bilty Image');
                  },
                  child: Text('Download Bilty Image'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImage(BuildContext context, String? imageUrl, String imageLabel) {
    if (imageUrl != null) {
      return GestureDetector(
        onTap: () {
          showImageDialog(context, imageUrl, imageLabel);
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
      return Text('No $imageLabel available.');
    }
  }

  void showImageDialog(
      BuildContext context, String imageUrl, String imageLabel) {
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

  void updateStatus(String newStatus) {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.document.id)
        .update({
      'status': newStatus,
    }).then((_) {
      setState(() {
        status = newStatus;
      });
    }).catchError((error) {
      print('Error updating status: $error');
    });
  }

  void showConfirmationDialog(String newStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Status Update'),
          content: Text(
              'Are you sure you want to update the status to "$newStatus"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateStatus(newStatus);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
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

void downloadImage(
    BuildContext context, String? imageUrl, String imageLabel) async {
  if (imageUrl != null) {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$imageLabel.jpg';

    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$imageLabel downloaded successfully.'),
        ),
      );
    } else {
      print('Failed to download $imageLabel: ${response.statusCode}');
    }
  } else {
    print('Image URL is null or empty.');
  }
}
