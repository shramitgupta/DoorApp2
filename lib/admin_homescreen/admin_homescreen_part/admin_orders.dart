import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({Key? key}) : super(key: key);

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        title: const Text(
          'Orders',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("orders").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              log(order.toString());
              final data = order.data() as Map<String, dynamic>;
              final img = data['orderpic'];
              final companyName =
                  data['companyName'] as String? ?? 'Unknown Company';
              final dealerEmail =
                  data['dealerEmail'] as String? ?? 'Unknown Email';

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Card(
                  elevation: 2,
                  child: OrderTile(
                    id: order.id, // Get the document ID
                    orderPicUrl: img,
                    companyName: companyName,
                    dealerEmail: dealerEmail,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrderTile extends StatefulWidget {
  final String companyName;
  final String dealerEmail;
  final String orderPicUrl;
  final String id;
  OrderTile({
    required this.id,
    required this.orderPicUrl,
    required this.companyName,
    required this.dealerEmail,
  });

  @override
  _OrderTileState createState() => _OrderTileState();
}

class _OrderTileState extends State<OrderTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.companyName),
      subtitle: Text(widget.dealerEmail),
      trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('View Attachment'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewerPage(
                        imageUrl: widget.orderPicUrl,
                        orderId: widget.id,
                      ),
                    ),
                  );
                },
              ),
              // Add more information or actions here
            ],
          ),
        ),
      ],
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
    );
  }
}

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final String orderId;

  ImageViewerPage({
    required this.imageUrl,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        title: const Text(
          'Attachment Viewer',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: PhotoViewGallery.builder(
                itemCount: 1,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(imageUrl),
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
                backgroundDecoration: BoxDecoration(
                  color: Colors.black,
                ),
                pageController: PageController(),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _updateOrderStatus(context, 'approved'); // Pass context here
                },
                child: Text('Approve'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  _updateOrderStatus(context, 'rejected'); // Pass context here
                },
                child: Text('Reject'),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  void _updateOrderStatus(BuildContext context, String status) async {
    try {
      final ordersCollection = FirebaseFirestore.instance.collection("orders");
      await ordersCollection.doc(orderId).update({'status': status});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order $status successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order status.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminOrders(),
  ));
}
