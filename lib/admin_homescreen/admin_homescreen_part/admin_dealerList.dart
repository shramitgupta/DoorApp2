import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDealerList extends StatefulWidget {
  const AdminDealerList({Key? key});

  @override
  State<AdminDealerList> createState() => _AdminDealerListState();
}

class _AdminDealerListState extends State<AdminDealerList> {
  late Future<int> _totalUsersCountFuture;
  bool _showSearchBar = false;
  String _searchQuery = '';
  late Timer _searchTimer;
  late Stream<QuerySnapshot> _searchStream;

  @override
  void initState() {
    super.initState();
    _totalUsersCountFuture = _getTotalUsersCount();
    _searchTimer = Timer(Duration(milliseconds: 500), () {});
    _searchStream = FirebaseFirestore.instance.collection("dealer").snapshots();
  }

  void _startSearchTimer() {
    if (_searchTimer.isActive) {
      _searchTimer.cancel();
    }
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        // Update the search stream based on the search query
        if (_searchQuery.isEmpty) {
          _searchStream =
              FirebaseFirestore.instance.collection("dealer").snapshots();
        } else {
          _searchStream = FirebaseFirestore.instance
              .collection("dealer")
              .where("companyname", isGreaterThanOrEqualTo: _searchQuery)
              .snapshots();
        }
      });
    });
  }

  Future<int> _getTotalUsersCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("dealer").get();
    return snapshot.docs.length;
  }

  @override
  void dispose() {
    _searchTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.brown.shade900,
        title: const Text(
          'DEALER LIST',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: '1',
                child: Text('Filter for location'),
              ),
              PopupMenuItem(
                value: '2',
                child: Text('Search'),
              ),
            ],
            onSelected: (value) {
              if (value == '1') {
                setState(() {
                  _showSearchBar = false;
                });
              } else if (value == '2') {
                setState(() {
                  _showSearchBar = true;
                });
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _showSearchBar
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _startSearchTimer();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                            _startSearchTimer();
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _searchStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error fetching data.'),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final List<DocumentSnapshot> documents =
                            snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final docData =
                                documents[index].data() as Map<String, dynamic>;
                            final title =
                                docData['companyname'] ?? 'No Company Name';
                            final subtitle = docData['email'] ?? 'No Email';
                            final ranking = (index + 1).toString();
                            final totalOrderPoints = docData['totalorder'] ?? 0;
                            return Card(
                              elevation: 6,
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.brown.shade900,
                                  child: Text(ranking),
                                ),
                                title: Text(title),
                                subtitle: Text(subtitle),
                                trailing: Text(
                                  '$totalOrderPoints',
                                  style: TextStyle(
                                    color: Colors.brown.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
            : FutureBuilder<int>(
                future: _totalUsersCountFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error fetching total users count.'),
                    );
                  }

                  final totalUsersCount = snapshot.data ?? 0;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AnimatedDefaultTextStyle(
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade900,
                          ),
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: Text('Total Users: $totalUsersCount'),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("dealer")
                              .orderBy("totalorder", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error fetching data.'),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final List<DocumentSnapshot> documents =
                                snapshot.data!.docs;
                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                final docData = documents[index].data()
                                    as Map<String, dynamic>;
                                final title =
                                    docData['companyname'] ?? 'No Company Name';
                                final subtitle = docData['email'] ?? 'No Email';
                                final ranking = (index + 1).toString();
                                final totalOrderPoints =
                                    docData['totalorder'] ?? 0;
                                return Card(
                                  elevation: 6,
                                  margin: const EdgeInsets.all(10),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.brown.shade900,
                                      child: Text(ranking),
                                    ),
                                    title: Text(title),
                                    subtitle: Text(subtitle),
                                    trailing: Text(
                                      '$totalOrderPoints',
                                      style: TextStyle(
                                        color: Colors.brown.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
