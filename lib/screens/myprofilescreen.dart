
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyProfileScreen extends StatefulWidget {
  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _namecontroller = TextEditingController();

  final _biocontroller = TextEditingController();

  final _emailcontroller = TextEditingController();

  String name = "";

  String bio = "";
  String? imageurl;

  String email = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> loaddetails() async {
    var instance = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    name = instance['username'].toString().toUpperCase();
    bio = instance['bio'].toString();
    email = instance['email'].toString();
    imageurl = instance['imageurl'].toString();
    print(imageurl);
    print(name);
    _namecontroller.text = name;
    _biocontroller.text = bio;
    _emailcontroller.text = email;
  }

  void updatedetails() async {
    if (_namecontroller.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'username': _namecontroller.text.toUpperCase(), 'bio': _biocontroller.text});
    } else {
      _showSuccessDialog(context);
    }
  }
  

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Name can't be empty ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color.fromARGB(255, 251, 7, 7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
    _namecontroller.text = name;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
          future: loaddetails(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: imageurl != null
                          ? CachedNetworkImageProvider(imageurl!)
                          : null,
                      child: imageurl == null ? Icon(Icons.person) : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _namecontroller,
                          decoration: InputDecoration(
                            labelText: "Name",
                            // hintText: "e.g. example@example.com",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefixIcon: Icon(Icons.person_2_rounded),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _biocontroller,
                          decoration: InputDecoration(
                            labelText: "Bio",
                            // hintText: "e.g. example@example.com",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefixIcon: Icon(Icons.info_rounded),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: false,
                          controller: _emailcontroller,
                          decoration: InputDecoration(
                            labelText: "Email",
                            // hintText: "e.g. example@example.com",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefixIcon: Icon(Icons.email_rounded),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: updatedetails, child: const Text("Update")),
                    const Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 20,
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
