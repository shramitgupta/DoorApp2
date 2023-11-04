import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorapp2/admin_homescreen/admin_homescreen_part/profile.dart';
import 'package:doorapp2/admin_homescreen/admin_homescreen_part/state_list.dart';
import 'package:flutter/material.dart';

class AdminDealerList extends StatefulWidget {
  const AdminDealerList({Key? key});

  @override
  State<AdminDealerList> createState() => _AdminDealerListState();
}

class _AdminDealerListState extends State<AdminDealerList> {
  late Future<int> _totalUsersCountFuture;
  bool _stateanddistrict = false;
  bool _showSearchBar = false;
  bool _showSearchPincode = false; // New state variable for pincode search
  String _searchQuery = '';
  String _pincodeSearchQuery = ''; // New state variable for pincode search
  late Timer _searchTimer;
  late Stream<QuerySnapshot> _searchStream;
  late Stream<QuerySnapshot>
      _pincodeSearchStream; // New stream for pincode search
  @override
  void initState() {
    super.initState();
    _totalUsersCountFuture = _getTotalUsersCount();
    _searchTimer = Timer(Duration(milliseconds: 500), () {});
    _searchStream = FirebaseFirestore.instance.collection("dealer").snapshots();
    _pincodeSearchStream = FirebaseFirestore.instance
        .collection("dealer")
        .snapshots(); // Initialize _pincodeSearchStream
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

  void _startPincodeSearch(String pincode) {
    if (_searchTimer.isActive) {
      _searchTimer.cancel();
    }
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        _pincodeSearchQuery = pincode;
        if (_pincodeSearchQuery.isEmpty) {
          _pincodeSearchStream =
              FirebaseFirestore.instance.collection("dealer").snapshots();
        } else {
          _pincodeSearchStream = FirebaseFirestore.instance
              .collection("dealer")
              .where("pin", isEqualTo: _pincodeSearchQuery)
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

  String selectedState = "Select State";
  String selectedDistrict = "District";
  int getMatchingCarpentersCount(List<QueryDocumentSnapshot> documents) {
    int count = 0;
    for (var document in documents) {
      if ((selectedState == "Select State" ||
              document["state"] == selectedState) &&
          (selectedDistrict == "District" ||
              document["district"] == selectedDistrict)) {
        count++;
      }
    }
    return count;
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
                value: '0',
                child: Text('Total Users'),
              ),
              PopupMenuItem(
                value: '1',
                child: Text('Filter for location'),
              ),
              PopupMenuItem(
                value: '2',
                child: Text('Company Name Search'),
              ),
              PopupMenuItem(
                value: '3',
                child: Text('Search Pincode'),
              ),
            ],
            onSelected: (value) {
              if (value == '0') {
                setState(() {
                  _stateanddistrict = false;
                  _showSearchBar = false;
                  _showSearchPincode = false;
                });
              } else if (value == '1') {
                setState(() {
                  _stateanddistrict = true;
                  _showSearchBar = false;
                  _showSearchPincode = false;
                });
              } else if (value == '2') {
                setState(() {
                  _stateanddistrict = false;
                  _showSearchBar = true;
                  _showSearchPincode = false;
                });
              } else if (value == '3') {
                setState(() {
                  _stateanddistrict = false;
                  _showSearchBar = false;
                  _showSearchPincode = true;
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
                            final totalOrderPoints =
                                docData['totalorders'] ?? 0;
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
            : _showSearchPincode
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          onChanged: (value) {
                            _startPincodeSearch(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Pincode...',
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _startPincodeSearch('');
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _pincodeSearchStream,
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
                                    docData['totalorders'] ?? 0;
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
                : _stateanddistrict
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedState,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedState = newValue!;
                                        selectedDistrict = "District";
                                      });
                                    },
                                    items: maincateg.map((state) {
                                      return DropdownMenuItem<String>(
                                        value: state,
                                        child: Text(state),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      labelText: 'Select State',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedDistrict,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedDistrict = newValue!;
                                      });
                                    },
                                    items: selectedState == "Select State"
                                        ? []
                                        : getDistrictList(selectedState)
                                            .map((district) {
                                            return DropdownMenuItem<String>(
                                              value: district,
                                              child: Text(district),
                                            );
                                          }).toList(),
                                    decoration: InputDecoration(
                                      labelText: 'Select District',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("dealer")
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
                                final filteredDocuments = documents
                                    .where((doc) =>
                                        (selectedState == "Select State" ||
                                            doc["state"] == selectedState) &&
                                        (selectedDistrict == "District" ||
                                            doc["district"] ==
                                                selectedDistrict))
                                    .toList();

                                return ListView.builder(
                                  itemCount: filteredDocuments.length,
                                  itemBuilder: (context, index) {
                                    final docData = filteredDocuments[index]
                                        .data() as Map<String, dynamic>;
                                    final title = docData['companyname'] ??
                                        'No Company Name';
                                    final subtitle =
                                        docData['email'] ?? 'No Email';
                                    final ranking = (index + 1).toString();
                                    final totalOrderPoints =
                                        docData['totalorders'] ?? 0;
                                    return Card(
                                      elevation: 6,
                                      margin: const EdgeInsets.all(10),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              Colors.brown.shade900,
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                      .orderBy("totalorders", descending: true)
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
                                        final title = docData['companyname'] ??
                                            'No Company Name';
                                        final subtitle =
                                            docData['email'] ?? 'No Email';
                                        final ranking = (index + 1).toString();
                                        final totalOrderPoints =
                                            docData['totalorders'] ?? 0;
                                        final documentId = documents[index].id;
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Profile(
                                                    documentId: documentId),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            elevation: 6,
                                            margin: const EdgeInsets.all(10),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    Colors.brown.shade900,
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

  List<String> getDistrictList(String state) {
    switch (state) {
      case "Andhra Pradesh":
        return AndhraPradesh;
      case "Arunachal Pradesh":
        return ArunachalPradesh;
      case "Assam":
        return Assam;
      case "Gujarat":
        return Gujarat;
      case "Bihar":
        return Bihar;
      case "Chhattisgarh":
        return Chhattisgarh;
      case "Goa":
        return Goa;
      case "Haryana":
        return Haryana;
      case "Himachal Pradesh":
        return HimachalPradesh;
      case "Jharkhand":
        return Jharkhand;
      case "Karnataka":
        return Karnataka;
      case "Kerala":
        return Kerala;
      case "Madhya Pradesh":
        return MadhyaPradesh;
      case "Maharashtra":
        return Maharashtra;
      case "Manipur":
        return Manipur;
      case "Meghalaya":
        return Meghalaya;
      case "Mizoram":
        return Mizoram;
      case "Nagaland":
        return Nagaland;
      case "Orissa":
        return Orissa;
      case "Punjab":
        return Punjab;
      case "Rajasthan":
        return Rajasthan;
      case "Sikkim":
        return Sikkim;
      case "Tamil Nadu":
        return TamilNadu;
      case "Telangana":
        return Telangana;
      case "Tripura":
        return Tripura;
      case "Uttar Pradesh":
        return UttarPradesh;
      case "Uttarakhand":
        return Uttarakhand;
      case "West Bengal":
        return WestBengal;
      default:
        return [];
    }
  }
}
