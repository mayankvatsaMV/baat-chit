import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

var currentuser = FirebaseAuth.instance.currentUser;

class NewFriendScreen extends StatefulWidget {
  @override
  State<NewFriendScreen> createState() => _NewFriendScreenState();
}

class _NewFriendScreenState extends State<NewFriendScreen> {
  late String hello;

  String? friendid;

  bool showerror = false;
  late List<dynamic> friendIds;
  DocumentSnapshot? friendInstance;
  var _textcontroller = TextEditingController();
  bool alreadyfriend = false;
  bool addedSuccessfully = false;
  bool addingMyself = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showerror = false;
  }

  void addFriend() async {
    try {
      var temp = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentuser!.uid)
          .get();
      if (_textcontroller.text == temp['email']) {
        setState(() {
          addingMyself = true;
        });
        return;
      } else {
        QuerySnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: _textcontroller.text)
                .get();

        if (userSnapshot.docs.isNotEmpty) {
          DocumentSnapshot checkuserSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userSnapshot.docs.first.id)
              .get();

          List<dynamic>? friends = checkuserSnapshot['friends'];

          bool isCurrentUserFriend =
              friends != null && friends.contains(currentuser!.uid);

          if (isCurrentUserFriend) {
            print('Current user is already a friend.');
            setState(() {
              alreadyfriend = true;
            });
            return;
          } else {
            String friendId = userSnapshot.docs.first.id;
            friendid = friendId;
            await FirebaseFirestore.instance
                .collection('users')
                .doc(friendId)
                .update({
              'friends': FieldValue.arrayUnion([currentuser!.uid]),
            });

            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentuser!.uid)
                .update({
              'friends': FieldValue.arrayUnion([friendid]),
            });

            setState(() {
              addedSuccessfully = true;
              if (addedSuccessfully) {
                _showSuccessDialog(context);
                setState(() {
                  addedSuccessfully = false;
                });
              }
            });
          }
        } else {
          setState(() {
            showerror = true;
            alreadyfriend = false;
            addingMyself = false;
          });
        }
      }
    } catch (e) {
      print('Error accessing friends field: $e');
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Friend Added Successfully',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.green,
            ),
          ),
          content: const Text(
            'Congratulations! You have successfully added a new friend.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Image.asset('assets/images/add-user.png'),
              ),
            ),
            const Text(
              "Lets Connect....",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                onTapOutside: (event) {
                  setState(() {
                    showerror = false;
                    alreadyfriend = false;
                    addingMyself = false;
                  });
                },
                controller: _textcontroller,
                decoration: InputDecoration(
                  labelText: "Enter Email-Id",
                  hintText: "e.g. example@example.com",
                  errorText: addingMyself == true
                      ? "Can't add yourself as friend"
                      : showerror == true
                          ? "User not found"
                          : (alreadyfriend == true ? "Already Friend" : null),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(Icons.email),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _textcontroller.clear();
                    },
                    child: Icon(Icons.clear),
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
            ElevatedButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Adjust the radius as needed
                ),
              ),
              onPressed: () {
                addFriend();
              },
              child: Text("Add Friend"),
            ),
            Expanded(
                child: SizedBox(
              height: 10,
            ))
          ],
        ),
      ),
    );
  }
}
