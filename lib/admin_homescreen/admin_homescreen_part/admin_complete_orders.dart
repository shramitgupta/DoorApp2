import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminCompleteOrders extends StatefulWidget {
  const AdminCompleteOrders({Key? key}) : super(key: key);

  @override
  State<AdminCompleteOrders> createState() => _AdminCompleteOrdersState();
}

class _AdminCompleteOrdersState extends State<AdminCompleteOrders>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CollectionReference _ordersCollection;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ordersCollection = FirebaseFirestore.instance.collection('orders');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        title: const Text(
          'Orders Completed',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dispatched'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersTab('Dispatched'),
          _buildOrdersTab('Received'),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _ordersCollection
          .where('status', isEqualTo: status)
          .orderBy('ordertime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No $status orders available.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final orderData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            final companyName = orderData['companyName'] as String? ??
                'Company Name Not Available';
            final dealerEmail =
                orderData['dealerEmail'] as String? ?? 'Email Not Available';

            final timestamp = orderData['ordertime'] as Timestamp?;
            final formattedTimestamp = timestamp != null
                ? DateFormat.yMd().add_Hms().format(timestamp.toDate())
                : 'Time Not Available';

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ExpansionTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      dealerEmail,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Date and Time: $formattedTimestamp',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                children: [
                  _buildImageTile(
                      orderData['orderpic'] as String?, 'Order Image'),
                  _buildImageTile(orderData['bill'] as String?, 'Bill Image'),
                  _buildImageTile(orderData['bilty'] as String?, 'Bilty Image'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageTile(String? imageUrl, String title) {
    if (imageUrl == null) {
      return ListTile(
        title: Text("$title (Not Available)"),
      );
    }

    return GestureDetector(
      onTap: () {
        _showImageDialog(imageUrl);
      },
      child: ListTile(
        title: Text(title),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Image.network(imageUrl),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
