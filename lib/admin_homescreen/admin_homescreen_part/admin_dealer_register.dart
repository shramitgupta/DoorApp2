import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorapp2/admin_homescreen/admin_homescreen_part/state_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class DealerRegister extends StatefulWidget {
  const DealerRegister({super.key});

  @override
  State<DealerRegister> createState() => _DealerRegisterState();
}

class _DealerRegisterState extends State<DealerRegister> {
  TextEditingController snameController = TextEditingController();
  TextEditingController spnoController = TextEditingController();
  TextEditingController saddressController = TextEditingController();
  TextEditingController sageController = TextEditingController();
  TextEditingController smaritalstatusController = TextEditingController();
  TextEditingController sdobController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController cnoController = TextEditingController();
  TextEditingController companynameController = TextEditingController();
  TextEditingController pannoController = TextEditingController();
  TextEditingController aadharnoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController? sanniversarydateController;

  File? sprofilepic;
  int totalorders = 0;

  bool isLoading = false;
  String? cmaritalstatus; // Track the marital status
  String? m = 'NA';
  String mainCategValue = 'Select State';
  String subCategValue = 'District';

  List<String> subCategList = [];
  @override
  void initState() {
    super.initState();
    cmaritalstatus = "Married"; // Default value for marital status
    sanniversarydateController = TextEditingController();
  }

  Future<void> _createUserAndUploadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      String email = emailController.text.trim();
      String password = passController.text.trim();

      bool userExists = await _checkUserExists(email);

      if (userExists) {
        _showMessage('User with this email already exists!', Colors.red);
      } else {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String uid = userCredential.user?.uid ?? '';

        await _uploadData(uid);

        clearFields();
        _showMessage('Registered successfully!', Colors.green);
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print('Error creating user: $error');
    }
  }

  Future<bool> _checkUserExists(String email) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: 'randomPassword',
      );
      return true;
    } catch (error) {
      return false;
    }
  }

  void _showMessage(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
    );
  }

  Future<void> _getImageFromSource(ImageSource source) async {
    XFile? selectedImage = await ImagePicker().pickImage(source: source);

    if (selectedImage != null) {
      File convertedFile = File(selectedImage.path);
      setState(() {
        sprofilepic = convertedFile;
      });
      log('Image selected!');
    } else {
      log('No image selected!');
    }
  }

  bool isStateDistrictSelected() {
    return mainCategValue != 'Select State' && subCategValue != 'District';
  }

  bool areAllFieldsFilled() {
    var a = gstController.text.isNotEmpty &&
        cnoController.text.isNotEmpty &&
        companynameController.text.isNotEmpty &&
        pannoController.text.isNotEmpty &&
        aadharnoController.text.isNotEmpty &&
        pinController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passController.text.isNotEmpty &&
        snameController.text.isNotEmpty &&
        spnoController.text.isNotEmpty &&
        saddressController.text.isNotEmpty &&
        sageController.text.isNotEmpty &&
        sdobController.text.isNotEmpty &&
        (cmaritalstatus != 'Married' ||
            sanniversarydateController!.text.isNotEmpty) &&
        sprofilepic != null &&
        isStateDistrictSelected();
    log(gstController.text.isNotEmpty.toString() +
        cnoController.text.isNotEmpty.toString() +
        companynameController.text.isNotEmpty.toString() +
        pannoController.text.isNotEmpty.toString() +
        aadharnoController.text.isNotEmpty.toString() +
        pinController.text.isNotEmpty.toString() +
        emailController.text.isNotEmpty.toString() +
        passController.text.isNotEmpty.toString() +
        snameController.text.isNotEmpty.toString() +
        spnoController.text.isNotEmpty.toString() +
        saddressController.text.isNotEmpty.toString() +
        sageController.text.isNotEmpty.toString() +
        sdobController.text.isNotEmpty.toString() +
        (cmaritalstatus != 'Married' ||
                sanniversarydateController!.text.isNotEmpty)
            .toString() +
        (sprofilepic != null).toString() +
        isStateDistrictSelected().toString());
    return a; // Check if state and district are selected
  }

  String getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    log(FirebaseAuth.instance.currentUser.toString());
    return user?.uid ?? '';
  }

  Future<void> _uploadData(String uid) async {
    setState(() {
      isLoading = true;
    });
    String cname = snameController.text.trim();
    String cpnoString = spnoController.text.trim();
    String caddress = saddressController.text.trim();
    String cageString = sageController.text.trim();
    String cdob = sdobController.text.trim();
    String email = emailController.text.trim();
    String password = passController.text.trim();
    String gstno = gstController.text.trim();
    String comapnyno = cnoController.text.trim();
    String companyname = companynameController.text.trim();
    String panno = pannoController.text.trim();
    String aadharno = aadharnoController.text.trim();
    String pin = pinController.text.trim();

    int cpno = int.parse(cpnoString);
    int cage = int.parse(cageString);
    String uid = getCurrentUserId();

    if (gstno.isNotEmpty &&
        comapnyno.isNotEmpty &&
        companyname.isNotEmpty &&
        panno.isNotEmpty &&
        aadharno.isNotEmpty &&
        pin.isNotEmpty &&
        password.isNotEmpty &&
        email.isNotEmpty &&
        cname.isNotEmpty &&
        cpnoString.isNotEmpty &&
        caddress.isNotEmpty &&
        cageString.isNotEmpty &&
        cmaritalstatus != null &&
        cdob.isNotEmpty &&
        (cmaritalstatus != 'Married' ||
            sanniversarydateController!.text.isNotEmpty) &&
        sprofilepic != null) {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("sprofilepic")
          .child(Uuid().v1())
          .putFile(sprofilepic!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      Map<String, dynamic> dealerData = {
        "cname": cname,
        "cpno": cpno,
        'email': email,
        'gstno': gstno,
        'companyno': comapnyno,
        'companyname': companyname,
        'panno': panno,
        'aadharno': aadharno,
        "caddress": caddress,
        "cage": cage,
        "cmaritalstatus": cmaritalstatus,
        "sprofilepic": downloadUrl,
        "cdob": cdob,
        "totalorders": totalorders,
        "canniversarydate": m,
        "state": mainCategValue,
        "district": subCategValue,
        'pin': pin,
      };

      String existingAnniversaryDate = dealerData["canniversarydate"] ??
          ''; // Get the existing anniversary date from the document

      if (cmaritalstatus == 'Married') {
        if (sanniversarydateController!.text == existingAnniversaryDate) {
          // If "Anniversary Date" is the same as the existing value, ask for confirmation.
          bool updateConfirmation = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Confirm Update'),
                content: Text(
                  'The selected Anniversary Date is the same as the existing one. Do you want to update it?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('No'),
                  ),
                ],
              );
            },
          );

          if (updateConfirmation != true) {
            // If the user does not confirm the update, set "Anniversary Date" to the existing value.
            sanniversarydateController!.text = existingAnniversaryDate;
          }
        }

        dealerData["canniversarydate"] = sanniversarydateController!.text;
      }

      await FirebaseFirestore.instance
          .collection("dealer")
          .doc(uid)
          .set(dealerData);
      print('Data Uploaded');

      // Clear fields after successful data upload
      clearFields();
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
        msg: "Registered successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      log('Fill in all data fields');
    }
  }

  void clearFields() {
    setState(() {
      addressController.clear();
      aadharnoController.clear();
      pannoController.clear();
      companynameController.clear();
      cnoController.clear();
      gstController.clear();
      passController.clear();
      emailController.clear();
      pinController.clear();
      snameController.clear();
      spnoController.clear();
      saddressController.clear();
      sageController.clear();
      smaritalstatusController.clear();
      sdobController.clear();
      sanniversarydateController?.clear();
      sprofilepic = null;
      mainCategValue = 'Select State';
      subCategValue = 'District';
    });
  }

  Future<void> _selectDOB(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        sdobController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
    setState(() {});
  }

  Future<void> _selectAnniversaryDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        sanniversarydateController!.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
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

    print(value);
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
          'CARPENTER REGISTER',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        return Container(
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
                        onTap: isLoading
                            ? null
                            : () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          onTap: () {
                                            Navigator.pop(context);
                                            _getImageFromSource(
                                                ImageSource.gallery);
                                          },
                                          leading: Icon(Icons.photo_library),
                                          title: Text("Choose from Gallery"),
                                        ),
                                        ListTile(
                                          onTap: () {
                                            Navigator.pop(context);
                                            _getImageFromSource(
                                                ImageSource.camera);
                                          },
                                          leading: Icon(Icons.camera_alt),
                                          title: Text("Take a Photo"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: (sprofilepic != null)
                                ? DecorationImage(
                                    image: FileImage(sprofilepic!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: Colors.brown.shade200,
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: snameController,
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
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      controller: spnoController,
                      enabled:
                          !isLoading, // Disable the field when isLoading is true
                      cursorColor: Colors.brown.shade900,
                      decoration: InputDecoration(
                        counter: const Offstage(),
                        labelText: 'Enter Contact No',
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
                          child: Text(value),
                          enabled: !isLoading,
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
                        print(value);
                        setState(() {
                          subCategValue = value!;
                        });
                      },
                      items:
                          subCategList.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                          enabled: !isLoading,
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
                      controller: saddressController,
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
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      controller: sageController,
                      enabled:
                          !isLoading, // Disable the field when isLoading is true
                      cursorColor: Colors.brown.shade900,
                      decoration: InputDecoration(
                        counter: const Offstage(),
                        labelText: 'Enter Age',
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
                      value: cmaritalstatus,
                      onChanged: (newValue) {
                        setState(() {
                          cmaritalstatus = newValue;
                          if (cmaritalstatus == 'Married') {
                            sanniversarydateController?.clear();
                          }
                        });
                      },
                      items: <String>['Married', 'Not Married']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        enabled: !isLoading,
                        labelText: 'Marital Status',
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
                  if (cmaritalstatus == 'Married')
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: sanniversarydateController,
                        enabled: !isLoading,
                        cursorColor: Colors.brown.shade900,
                        onTap: () {
                          _selectAnniversaryDate(context);
                        },
                        decoration: InputDecoration(
                          labelText: 'Enter Anniversary Date',
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
                      controller: sdobController,
                      enabled: !isLoading,
                      cursorColor: Colors.brown.shade900,
                      onTap: () {
                        _selectDOB(context);
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter DOB',
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
                      onChanged: (value) {
                        setState(() {});
                      },
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
                            : _createUserAndUploadData,
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
      }),
      floatingActionButton: isLoading
          ? Center(
              child: FloatingActionButton(
                onPressed: null,
                backgroundColor: Colors.white,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            )
          : null,
    );
  }
}
