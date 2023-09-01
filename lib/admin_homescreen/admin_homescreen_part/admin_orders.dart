import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({Key? key}) : super(key: key);

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedOrderStatus = 'Not Approved';
  final tabStatuses = [
    'Not Approved',
    'Approved',
    'Sizing Done',
    'Posting Done',
    'Packing Done',
    'Dispatched',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        bottom: TabBar(
          controller: _tabController,
          tabs: tabStatuses.map((status) {
            return Tab(
              text: '$status (${_getOrderCount(status)})',
            );
          }).toList(),
          onTap: (index) {
            setState(() {
              _selectedOrderStatus = tabStatuses[index];
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabStatuses.map((status) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("orders")
                .where('status', isEqualTo: status)
                .orderBy('ordertime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final orders = snapshot.data!.docs;
              final filteredOrders = orders
                  .where((order) =>
                      (order['status'] as String?) == _selectedOrderStatus)
                  .toList();

              return ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  final data = order.data() as Map<String, dynamic>;
                  final img = data['orderpic'];
                  final companyName =
                      data['companyName'] as String? ?? 'Unknown Company';
                  final dealerEmail =
                      data['dealerEmail'] as String? ?? 'Unknown Email';
                  final orderTime = data['ordertime'] as Timestamp?;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Card(
                      elevation: 2,
                      child: OrderTile(
                        id: order.id,
                        orderPicUrl: img,
                        companyName: companyName,
                        dealerEmail: dealerEmail,
                        orderTime: orderTime,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }

  // Function to get the count of orders for a specific status
  Future<int> _getOrderCount(String status) async {
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection("orders")
        .where('status', isEqualTo: status)
        .get();

    return ordersSnapshot.size;
  }
}

class OrderTile extends StatefulWidget {
  final String companyName;
  final String dealerEmail;
  final String orderPicUrl;
  final String id;
  final Timestamp? orderTime;
  OrderTile({
    required this.id,
    required this.orderPicUrl,
    required this.companyName,
    required this.dealerEmail,
    required this.orderTime,
  });

  @override
  _OrderTileState createState() => _OrderTileState();
}

class _OrderTileState extends State<OrderTile> {
  bool _isExpanded = false;
  String _orderStatus = 'Not Approved'; // Default status
  File? _billImage;
  File? _biltyImage;
  ScaffoldMessengerState? _scaffoldMessengerState;
  String? biltyImageUrl = null;
  String? billImageUrl = null;
  bool _isUploadingBillImage = false;
  bool _isUploadingBiltyImage = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessengerState = ScaffoldMessenger.of(context);
  }

  void _fetchOrderStatus() async {
    try {
      final orderSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.id)
          .get();

      if (mounted) {
        setState(() {
          _orderStatus = orderSnapshot.get('status') ?? 'Not Approved';
        });
      }
    } catch (e) {
      print('Error fetching order status: $e');
    }
  }

  void _updateOrderStatus(BuildContext context, String status) async {
    if (!mounted) {
      return; // Widget is no longer in the tree
    }

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
                Navigator.of(dialogContext).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
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

        // Update the order status
        await ordersCollection.doc(widget.id).update({'status': status});

        if (billImageUrl != null) {
          await ordersCollection.doc(widget.id).update({'bill': billImageUrl});
        }

        if (biltyImageUrl != null) {
          await ordersCollection
              .doc(widget.id)
              .update({'bilty': biltyImageUrl});
        }

        if (mounted) {
          setState(() {
            _orderStatus = status;
          });

          _scaffoldMessengerState?.showSnackBar(
            SnackBar(
              content: Text('Order $status successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _scaffoldMessengerState?.showSnackBar(
            SnackBar(
              content: Text('Error updating order status.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<File?> _getImageFromSource(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.companyName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.email,
                color: Colors.grey,
                size: 18,
              ),
              SizedBox(width: 4),
              Text(
                widget.dealerEmail,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.grey,
                size: 18,
              ),
              SizedBox(width: 4),
              Text(
                // Format the order time using DateFormat
                widget.orderTime != null
                    ? 'Order Time: ${DateFormat('dd-MM-yyyy hh:mm a').format(widget.orderTime!.toDate())}'
                    : 'Order Time: N/A',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
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
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: (_billImage == null || _biltyImage == null)
                              ? () {
                                  _uploadBillAndBiltyImages(context);
                                }
                              : null,
                          child: _isUploadingBillImage || _isUploadingBiltyImage
                              ? CircularProgressIndicator()
                              : Text('Upload Bill and Bilty Images'),
                        ),
                      ],
                    ),
                  ],
                ),
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

  Future<void> _uploadBillAndBiltyImages(BuildContext context) async {
    final billImageFile = await _getImageFromSource(ImageSource.gallery);
    final biltyImageFile = await _getImageFromSource(ImageSource.gallery);

    if (billImageFile == null || biltyImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both bill and bilty images.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploadingBillImage = true;
      _isUploadingBiltyImage = true;
    });

    final billUploadTask = _uploadImage(billImageFile);
    final biltyUploadTask = _uploadImage(biltyImageFile);

    try {
      final List<String?> results =
          await Future.wait([billUploadTask, biltyUploadTask]);

      billImageUrl = results[0];
      biltyImageUrl = results[1];

      if (billImageUrl != null && biltyImageUrl != null) {
        setState(() {
          _billImage = billImageFile;
          _biltyImage = biltyImageFile;
          billImageUrl = billImageUrl;
          biltyImageUrl = biltyImageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bill and bilty images uploaded successfully.'),
            backgroundColor: Colors.green,
          ),
        );

        // Update the order status to 'Dispatched' after both images are uploaded
        _updateOrderStatus(context, 'Dispatched');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading images.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingBillImage = false;
        _isUploadingBiltyImage = false;
      });
    }
  }

  // Function to upload an image to Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final imageName =
          widget.id + '_' + DateTime.now().millisecondsSinceEpoch.toString();
      final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('order_images/$imageName.jpg');

      final uploadTask = firebaseStorageRef.putFile(imageFile);
      final storageSnapshot = await uploadTask;

      if (storageSnapshot.state == firebase_storage.TaskState.success) {
        final imageUrl = await firebaseStorageRef.getDownloadURL();
        return imageUrl;
      } else {
        print('Image upload failed: ${storageSnapshot.state}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
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
