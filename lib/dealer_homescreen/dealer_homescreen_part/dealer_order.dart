import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class PlaceOrder extends StatefulWidget {
  const PlaceOrder({super.key});

  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  File? orderpic;
  String status = 'Not Approved';
  Future<void> _getImageFromSource(ImageSource source) async {
    XFile? selectedImage = await ImagePicker().pickImage(source: source);

    if (selectedImage != null) {
      File convertedFile = File(selectedImage.path);
      setState(() {
        orderpic = convertedFile;
      });
      log('Image selected!');
    } else {
      log('No image selected!');
    }
  }

  bool isUploading = false;

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Order successfully Placed!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading'),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Please wait...'),
            ],
          ),
        );
      },
    );
  }

  Future<void> placeorder() async {
    setState(() {
      isUploading = true;
    });

    if (orderpic == null) {
      showErrorSnackbar('Please Upload the picture.');
      setState(() {
        isUploading = false;
      });
      return;
    }

    if (orderpic != null) {
      showLoadingDialog(); // Show the loading dialog

      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("orderpictures")
          .child(const Uuid().v1())
          .putFile(orderpic!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Get current dealer's data from "current dealer" collection
      DocumentSnapshot dealerSnapshot = await FirebaseFirestore.instance
          .collection("dealer")
          .doc(userId)
          .get();
      log(userId.toString());
      log(dealerSnapshot.data().toString());

      String companyname = dealerSnapshot['companyname'];
      String dealerEmail = dealerSnapshot['email'];

      Map<String, dynamic> orderData = {
        "status": status,
        "orderpic": downloadUrl,
        "userId": userId,
        "companyName": companyname,
        "dealerEmail": dealerEmail,
      };
      FirebaseFirestore.instance.collection("orders").add(orderData);

      setState(() {
        isUploading = false;
        orderpic = null;
      });

      Navigator.pop(context); // Hide the loading dialog
      showSuccessDialog(); // Show the success dialog
    } else {
      log('fill data');
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        title: const Text(
          'Place Orders',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _getImageFromSource(ImageSource.gallery);
                                },
                                leading: const Icon(Icons.photo_library),
                                title: const Text("Choose from Gallery"),
                              ),
                              ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _getImageFromSource(ImageSource.camera);
                                },
                                leading: const Icon(Icons.camera_alt),
                                title: const Text("Take a Photo"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height:
                          screenHeight * 0.75, // Adjust the height as needed
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: (orderpic != null)
                            ? DecorationImage(
                                image: FileImage(orderpic!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.brown.shade200,
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
                      onPressed: () {
                        placeorder();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 7.0,
                        ),
                        backgroundColor: Colors.brown.shade900,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Upload",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                // Rest of your UI
              ],
            ),
          ),
        ),
      ),
    );
  }
}
