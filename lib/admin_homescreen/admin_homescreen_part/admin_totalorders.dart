import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TotalOrders extends StatefulWidget {
  const TotalOrders({Key? key}) : super(key: key);

  @override
  State<TotalOrders> createState() => _TotalOrdersState();
}

class _TotalOrdersState extends State<TotalOrders>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _totalOrdersAnimation;
  late Animation<int> _approvedOrdersAnimation;
  late Animation<int> _newOrdersAnimation;
  late Animation<int> _rejectedOrdersAnimation;
  late Animation<int> _receivedOrdersAnimation;
  late Animation<int> _dispatchedOrdersAnimation;
  int receivedOrders = 0;
  int totalOrders = 0;
  int approvedOrders = 0;
  int newOrders = 0;
  int rejectedOrders = 0;
  int dispatchedOrders = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _totalOrdersAnimation = IntTween(begin: 0, end: totalOrders).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _approvedOrdersAnimation = IntTween(begin: 0, end: approvedOrders).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _newOrdersAnimation = IntTween(begin: 0, end: newOrders).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rejectedOrdersAnimation = IntTween(begin: 0, end: rejectedOrders).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _receivedOrdersAnimation = IntTween(begin: 0, end: receivedOrders).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _dispatchedOrdersAnimation =
        IntTween(begin: 0, end: dispatchedOrders).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fetchOrderCounts();
  }

  Future<void> _fetchOrderCounts() async {
    try {
      final QuerySnapshot totalSnapshot =
          await FirebaseFirestore.instance.collection("orders").get();

      final QuerySnapshot approvedSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where('status', isEqualTo: 'Approved')
          .get();

      final QuerySnapshot newSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where('status', isEqualTo: 'Not Approved')
          .get();

      final QuerySnapshot rejectedSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where('status', isEqualTo: 'rejected')
          .get();

      final QuerySnapshot receivedSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where('status', isEqualTo: 'Received')
          .get();

      final QuerySnapshot dispatchedSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where('status', isEqualTo: 'Dispatched')
          .get();

      setState(() {
        dispatchedOrders = dispatchedSnapshot.size;
        receivedOrders = receivedSnapshot.size;
        totalOrders = totalSnapshot.size;
        approvedOrders = approvedSnapshot.size;
        newOrders = newSnapshot.size;
        rejectedOrders = rejectedSnapshot.size;

        _totalOrdersAnimation = IntTween(begin: 0, end: totalOrders).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );

        _approvedOrdersAnimation =
            IntTween(begin: 0, end: approvedOrders).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );

        _newOrdersAnimation = IntTween(begin: 0, end: newOrders).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );

        _rejectedOrdersAnimation =
            IntTween(begin: 0, end: rejectedOrders).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );

        _receivedOrdersAnimation =
            IntTween(begin: 0, end: receivedOrders).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );

        _dispatchedOrdersAnimation =
            IntTween(begin: 0, end: dispatchedOrders).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );

        _controller.forward();
      });
    } catch (error) {
      print("Error fetching orders: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        title: const Text(
          'Orders Count',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildOrderCategoryTile(
            label: 'Total Orders',
            animation: _totalOrdersAnimation,
            statusFilter: null,
          ),
          _buildOrderCategoryTile(
            label: 'Approved Orders',
            animation: _approvedOrdersAnimation,
            statusFilter: 'Approved',
          ),
          _buildOrderCategoryTile(
            label: 'New Orders',
            animation: _newOrdersAnimation,
            statusFilter: 'Not Approved',
          ),
          _buildOrderCategoryTile(
            label: 'Rejected Orders',
            animation: _rejectedOrdersAnimation,
            statusFilter: 'rejected',
          ),
          _buildOrderCategoryTile(
            label: 'Received Orders',
            animation: _receivedOrdersAnimation,
            statusFilter: 'Received',
          ),
          _buildOrderCategoryTile(
            label: 'Dispatched Orders',
            animation: _dispatchedOrdersAnimation,
            statusFilter: 'Dispatched',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCategoryTile({
    required String label,
    required Animation<int> animation,
    String? statusFilter,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderListScreen(statusFilter),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Text(
                    animation.value.toString(),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade900,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class OrderListScreen extends StatelessWidget {
  final String? statusFilter;

  OrderListScreen(this.statusFilter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        title: Text(
          statusFilter == null ? 'All Orders' : statusFilter!,
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: statusFilter == null
            ? FirebaseFirestore.instance.collection("orders").snapshots()
            : FirebaseFirestore.instance
                .collection("orders")
                .orderBy('ordertime', descending: true)
                .where('status', isEqualTo: statusFilter)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Text("No orders found."),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final documentId = orders[index].id;
              return OrderListItem(order: order);
            },
          );
        },
      ),
    );
  }
}

class OrderListItem extends StatelessWidget {
  final Map<String, dynamic> order;

  OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final String companyName = order['companyName'];
    final String dealerEmail = order['dealerEmail'];
    final Timestamp? orderTime = order['ordertime']; // Make orderTime nullable

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(
          companyName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.email,
                  color: Colors.grey,
                  size: 18,
                ),
                SizedBox(width: 4),
                Text(
                  dealerEmail,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (orderTime != null) // Check if orderTime is not null
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.grey,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Order Time: ${DateFormat('dd-MM-yyyy hh:mm a').format(orderTime.toDate())}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            if (orderTime == null) // Handle case when orderTime is null
              Text(
                'Order Time: N/A',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
