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
  String _orderStatus = 'Not Approved'; // Default status

  @override
  void initState() {
    super.initState();
    _fetchOrderStatus(); // Fetch order status when the widget is initialized
  }

  void _fetchOrderStatus() async {
    try {
      final orderSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.id)
          .get();

      setState(() {
        _orderStatus = orderSnapshot.get('status') ?? 'Not Approved';
      });
    } catch (e) {
      print('Error fetching order status: $e');
    }
  }

  void _updateOrderStatus(BuildContext context, String status) async {
    // Show a confirmation alert dialog
    bool shouldUpdate = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(
              'Are you sure you want to update the order status to $status?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Cancel the update
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Confirm the update
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (shouldUpdate == true) {
      try {
        final ordersCollection =
            FirebaseFirestore.instance.collection("orders");
        await ordersCollection.doc(widget.id).update({'status': status});

        setState(() {
          _orderStatus = status;
        });

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
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('View Attachment'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewerPage(
                              imageUrl: widget.orderPicUrl,
                              orderId: widget.id,
                              orderStatus: _orderStatus,
                              updateOrderStatus: _updateOrderStatus,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (_orderStatus == 'Not Approved')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _updateOrderStatus(context, 'Approved');
                      },
                      child: Text('Approved'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        _updateOrderStatus(context, 'rejected');
                      },
                      child: Text('Reject'),
                    ),
                  ],
                ),
              if (_orderStatus == 'Approved')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _updateOrderStatus(context, 'Sizing Done');
                      },
                      child: Text('Sizing Done'),
                    ),
                  ],
                ),
              if (_orderStatus == 'Sizing Done')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _updateOrderStatus(context, 'Posting Done');
                      },
                      child: Text('Posting Done'),
                    ),
                  ],
                ),
              if (_orderStatus == 'Posting Done')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _updateOrderStatus(context, 'Packing Done');
                      },
                      child: Text('Packing Done'),
                    ),
                  ],
                ),
              if (_orderStatus == 'Packing Done')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _updateOrderStatus(context, 'Dispatched');
                      },
                      child: Text('Dispatched'),
                    ),
                  ],
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
  final String orderStatus;
  final Function(BuildContext, String) updateOrderStatus;

  ImageViewerPage({
    required this.imageUrl,
    required this.orderId,
    required this.orderStatus,
    required this.updateOrderStatus,
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
        ],
      ),
    );
  }
}
