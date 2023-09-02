import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  int totalOrders = 0;
  int approvedOrders = 0;
  int newOrders = 0;
  int rejectedOrders = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Adjust animation duration as needed
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

      setState(() {
        // Update counts with data from Firestore
        totalOrders = totalSnapshot.size;
        approvedOrders = approvedSnapshot.size;
        newOrders = newSnapshot.size;
        rejectedOrders = rejectedSnapshot.size;

        // Update the animations with the new values
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

        // Start the animation
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
          _buildAnimatedCounter(
            label: 'Total Orders',
            animation: _totalOrdersAnimation,
          ),
          _buildAnimatedCounter(
            label: 'Approved Orders',
            animation: _approvedOrdersAnimation,
          ),
          _buildAnimatedCounter(
            label: 'New Orders',
            animation: _newOrdersAnimation,
          ),
          _buildAnimatedCounter(
            label: 'Rejected Orders',
            animation: _rejectedOrdersAnimation,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCounter({
    required String label,
    required Animation<int> animation,
  }) {
    return Card(
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
