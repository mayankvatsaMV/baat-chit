import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/openstoryscreen.dart';

final _firebase = FirebaseAuth.instance;

class MyStoryWidget extends StatefulWidget {
  @override
  State<MyStoryWidget> createState() => _MyStoryWidgetState();
}

class _MyStoryWidgetState extends State<MyStoryWidget> {
  File? pickedStoryImage;
  DocumentSnapshot? myStoryDocument;
  List<DocumentSnapshot> friendStoryDocument = [];
  List<dynamic>? friendIds;
  bool _isuploading = false;
  Timestamp addOneDayToTimestamp() {
    Timestamp currentTimestamp = Timestamp.now();
    DateTime currentDate = currentTimestamp.toDate();
    DateTime nextDate = currentDate.add(const Duration(days: 1));
    Timestamp nextTimestamp = Timestamp.fromDate(nextDate);
    return nextTimestamp;
  }

  LoadMyStoryImage() async {
    try {
      var temp = await FirebaseFirestore.instance
          .collection('story')
          .doc(_firebase.currentUser!.uid)
          .get();
      if (temp.exists) {
        myStoryDocument = temp;
      } else {
        myStoryDocument;
      }
    } catch (e) {
      // print('Error loading story image: $e');
    }
  }

  void uploadStory() async {
    var pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;
    setState(() {
      _isuploading = true;
    });
    pickedStoryImage = File(pickedImage.path);
    if (pickedStoryImage != null) {
      // Delete the previous image from storage
      try {
        await FirebaseStorage.instance
            .ref()
            .child("story")
            .child("${_firebase.currentUser!.uid}.jpg")
            .delete();
      } catch (e) {
        // Handle the deletion error
        print('Error deleting previous image: $e');
      }
    }

    var storageref = FirebaseStorage.instance
        .ref()
        .child("story")
        .child("${_firebase.currentUser!.uid}.jpg");

    await storageref.putFile(pickedStoryImage!);
    var storyUrl = await storageref.getDownloadURL();
    var usernameInstance = await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebase.currentUser!.uid)
        .get();
    FirebaseFirestore.instance
        .collection('story')
        .doc(_firebase.currentUser!.uid)
        .set({
      'createdAt': Timestamp.now(),
      'destroyAt': addOneDayToTimestamp(),
      'imageurl': storyUrl.toString(),
      'userName': usernameInstance['username'],
    });
    setState(() {
      _isuploading = false;
      LoadMyStoryImage();
    });
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('story')
            .doc(_firebase.currentUser!.uid)
            .get();
        // print(userSnapshot);
        if (userSnapshot.exists) {
          // String imageLink = userSnapshot['imageurl'];
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return OpenStory(snapshot: userSnapshot);
            }),
          );
        }
      },
      onLongPress: uploadStory,
      child: FutureBuilder(
        future: LoadMyStoryImage(),
        builder: (context, snapshot) {
          if (_isuploading) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              return CircleAvatar(
                radius: 28,
                backgroundImage: myStoryDocument != null
                    // ? NetworkImage(myStoryDocument?['imageurl'])
                    ? CachedNetworkImageProvider(myStoryDocument?['imageurl'])
                    : null,
                child: myStoryDocument == null ? const Icon(Icons.add) : null,
              );
            } else if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.active) {
              return const CircularProgressIndicator();
            } else {
              return const Icon(Icons.error);
            }
          }
        },
      ),
    );
  }
}
