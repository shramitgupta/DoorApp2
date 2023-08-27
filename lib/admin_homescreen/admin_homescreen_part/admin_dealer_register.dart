import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorapp2/admin_homescreen/admin_homescreen_part/state_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DealerRegister extends StatefulWidget {
  const DealerRegister({super.key});

  @override
  State<DealerRegister> createState() => _DealerRegisterState();
}

class _DealerRegisterState extends State<DealerRegister> {
  TextEditingController dnameController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController cnoController = TextEditingController();
  TextEditingController companynameController = TextEditingController();
  TextEditingController pannoController = TextEditingController();
  TextEditingController aadharnoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool isLoading = false;
  String mainCategValue = 'Select State';
  String subCategValue = 'District';
  List<String> subCategList = [];
  String statusMessage = '';
  int totalorder = 0;
  void signUp() async {
    setState(() {
      isLoading = true;
      statusMessage = '';
    });

    String email = emailController.text.trim();
    String password = passController.text.trim();
    String name = dnameController.text.trim();
    String gstno = gstController.text.trim();
    String comapnyno = cnoController.text.trim();
    String companyname = companynameController.text.trim();
    String panno = pannoController.text.trim();
    String aadharno = aadharnoController.text.trim();
    String address = addressController.text.trim();
    String pin = pinController.text.trim();

    if (email == '' || password == '') {
      setState(() {
        isLoading = false;
        statusMessage = 'Fill all fields.';
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Add user's email to Firestore collection
        await FirebaseFirestore.instance.collection('dealer').add({
          'email': email,
          'name': name,
          'gstno': gstno,
          'companyno': comapnyno,
          'companyname': companyname,
          'panno': panno,
          'aadharno': aadharno,
          'address': address,
          'pin': pin,
          'state': mainCategValue,
          'district': subCategValue,
          'totalorder': totalorder,
        });
        clearFields();
        setState(() {
          isLoading = false;
          statusMessage = 'Successfully signed up!';
        });
        Fluttertoast.showToast(
          msg: "Registered successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navigate to the next screen if needed
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextScreen()));
      }
    } on FirebaseAuthException catch (ex) {
      setState(() {
        isLoading = false;
        if (ex.code == 'email-already-in-use') {
          Fluttertoast.showToast(
            msg: "Email already in use.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          statusMessage = 'Email already in use.';
        } else {
          Fluttertoast.showToast(
            msg: "An error occurred. Please try again later.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          statusMessage = 'An error occurred. Please try again later.';
        }
      });
    }
  }

  void clearFields() {
    setState(() {
      dnameController.clear();
      gstController.clear();
      cnoController.clear();
      companynameController.clear();
      pannoController.clear();
      aadharnoController.clear();
      addressController.clear();
      pinController.clear();
      emailController.clear();
      passController.clear();
      mainCategValue = 'Select State';
      subCategValue = 'District';
    });
  }

  bool areAllFieldsFilled() {
    return dnameController.text.isNotEmpty &&
        gstController.text.isNotEmpty &&
        cnoController.text.isNotEmpty &&
        companynameController.text.isNotEmpty &&
        pannoController.text.isNotEmpty &&
        aadharnoController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        pinController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passController.text.isNotEmpty &&
        isStateDistrictSelected(); // Check if state and district are selected
  }

  bool isStateDistrictSelected() {
    return mainCategValue != 'Select State' && subCategValue != 'District';
  }

  void selectedMainCateg(String? value) {
    if (value == 'Select State') {
      subCategList = [];
    } else if (value == 'Andhra Pradesh') {
      subCategList = AndhraPradesh;
    } else if (value == 'Arunachal Pradesh') {
      subCategList = ArunachalPradesh;
    } else if (value == 'Assam') {
      subCategList = Assam;
    } else if (value == 'Gujarat') {
      subCategList = Gujarat;
    } else if (value == 'Bihar') {
      subCategList = Bihar;
    } else if (value == 'Chhattisgarh') {
      subCategList = Chhattisgarh;
    } else if (value == 'Goa') {
      subCategList = Goa;
    } else if (value == 'Haryana') {
      subCategList = Haryana;
    } else if (value == 'Himachal Pradesh') {
      subCategList = HimachalPradesh;
    } else if (value == 'Jharkhand') {
      subCategList = Jharkhand;
    } else if (value == 'Karnataka') {
      subCategList = Karnataka;
    } else if (value == 'Kerala') {
      subCategList = Kerala;
    } else if (value == 'Madhya Pradesh') {
      subCategList = MadhyaPradesh;
    } else if (value == 'Maharashtra') {
      subCategList = Maharashtra;
    } else if (value == 'Manipur') {
      subCategList = Manipur;
    } else if (value == 'Meghalaya') {
      subCategList = Meghalaya;
    } else if (value == 'Mizoram') {
      subCategList = Mizoram;
    } else if (value == 'Nagaland') {
      subCategList = Nagaland;
    } else if (value == 'Orissa') {
      subCategList = Orissa;
    } else if (value == 'Punjab') {
      subCategList = Punjab;
    } else if (value == 'Rajasthan') {
      subCategList = Rajasthan;
    } else if (value == 'Sikkim') {
      subCategList = Sikkim;
    } else if (value == 'Tamil Nadu') {
      subCategList = TamilNadu;
    } else if (value == 'Telangana') {
      subCategList = Telangana;
    } else if (value == 'Tripura') {
      subCategList = Tripura;
    } else if (value == 'Uttar Pradesh') {
      subCategList = UttarPradesh;
    } else if (value == 'Uttarakhand') {
      subCategList = Uttarakhand;
    } else if (value == 'West Bengal') {
      subCategList = WestBengal;
    }

    log(value.toString());
    setState(() {
      mainCategValue = value!;
      subCategValue = 'District';
    });
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
          'DEALER REGISTER',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          return SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: dnameController,
                        enabled:
                            !isLoading, // Disable the field when isLoading is true
                        cursorColor: Colors.brown.shade900,
                        decoration: InputDecoration(
                          labelText: 'Enter Name',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: gstController,
                        enabled:
                            !isLoading, // Disable the field when isLoading is true
                        cursorColor: Colors.brown.shade900,
                        decoration: InputDecoration(
                          labelText: 'Enter GST No',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: cnoController,
                        enabled:
                            !isLoading, // Disable the field when isLoading is true
                        cursorColor: Colors.brown.shade900,
                        decoration: InputDecoration(
                          labelText: 'Enter Company No',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: companynameController,
                        enabled:
                            !isLoading, // Disable the field when isLoading is true
                        cursorColor: Colors.brown.shade900,
                        decoration: InputDecoration(
                          labelText: 'Enter Company Name',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: pannoController,
                        enabled:
                            !isLoading, // Disable the field when isLoading is true
                        cursorColor: Colors.brown.shade900,
                        decoration: InputDecoration(
                          labelText: 'Enter Pan No',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: aadharnoController,
                        enabled:
                            !isLoading, // Disable the field when isLoading is true
                        cursorColor: Colors.brown.shade900,
                        decoration: InputDecoration(
                          labelText: 'Enter Aadhar No',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: addressController,
                        enabled:
                            !isLoading, // Disable the field when isLoading is true
                        cursorColor: Colors.brown.shade900,
                        decoration: InputDecoration(
                          labelText: 'Enter Address',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        value: mainCategValue,
                        onChanged: (String? value) {
                          selectedMainCateg(value);
                        },
                        items: maincateg.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            enabled: !isLoading,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Select State',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          enabled: !isLoading,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        value: subCategValue,
                        onChanged: (String? value) {
                          log(value.toString());
                          setState(() {
                            subCategValue = value!;
                          });
                        },
                        items:
                            subCategList.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            enabled: !isLoading,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Select District',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          enabled: !isLoading,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: pinController,
                        enabled:
                            !isLoading, // Disable the field when isLoading is true
                        cursorColor: Colors.brown.shade900,
                        decoration: InputDecoration(
                          labelText: 'Enter Pincode',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: emailController,
                        enabled:
                            !isLoading, // Disable the field when isLoading is true
                        cursorColor: Colors.brown.shade900,
                        decoration: InputDecoration(
                          labelText: 'Enter E-mail',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: passController,
                        enabled:
                            !isLoading, // Disable the field when isLoading is true
                        cursorColor: Colors.brown.shade900,
                        decoration: InputDecoration(
                          labelText: 'Enter Password',
                          labelStyle: TextStyle(color: Colors.brown.shade900),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                width: 3, color: Colors.brown.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading || !areAllFieldsFilled()
                              ? null
                              : signUp,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 7.0),
                            backgroundColor: Colors.brown.shade900,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            "Register",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: isLoading
          ? Center(
              child: FloatingActionButton(
                onPressed: null,
                backgroundColor: Colors.white,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.brown.shade900),
                ),
              ),
            )
          : null,
    );
  }
}
