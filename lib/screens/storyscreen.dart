import 'dart:async';
import 'dart:io';
import 'package:baatchit/screens/openstoryscreen.dart';
import 'package:baatchit/widgets/mystorywidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final _firebase = FirebaseAuth.instance;

class Storyscreen extends StatefulWidget {
  const Storyscreen({super.key});

  @override
  State<Storyscreen> createState() => _StoryscreenState();
}

class _StoryscreenState extends State<Storyscreen> {
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

  bool isLoadingFriends = false;

  @override
  void initState() {
    super.initState();
    deleteExpiredStories();
  }

  loadFriends() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebase.currentUser!.uid)
        .get();
    friendIds = userSnapshot['friends'];
  }

  Future<void> deleteExpiredStories() async {
    try {
      // Get all stories with destroyAt less than current time
      QuerySnapshot<Map<String, dynamic>> expiredStories =
          await FirebaseFirestore.instance
              .collection('story')
              .where('destroyAt', isLessThan: Timestamp.now())
              .get();

      // Delete each expired story
      if (expiredStories.docs.isNotEmpty) {
        for (QueryDocumentSnapshot<Map<String, dynamic>> doc
            in expiredStories.docs) {
          await FirebaseFirestore.instance
              .collection('story')
              .doc(doc.id)
              .delete();
        }
      }
    } catch (e) {
      print('Error deleting expired stories: $e');
    }
  }

  // ignore: non_constant_identifier_names
  LoadFriendStory() async {
    if (isLoadingFriends) {
      // Return if already loading to avoid concurrent calls
      return;
    }
    // print("hey");
    try {
      // print("hey 1");
      isLoadingFriends = true; // Set loading flag to true
      friendStoryDocument.clear();

      for (int i = 0; i < friendIds!.length; i++) {
        var temp = await FirebaseFirestore.instance
            .collection('story')
            .doc(friendIds![i])
            .get();
        if (temp.exists) {
          friendStoryDocument.add(temp);
        }
      }
    } catch (e) {
      // print('Error loading friend story image: $e');
    } finally {
      isLoadingFriends = false; // Reset loading flag in finally block
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Status",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  MyStoryWidget(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  const Text(
                    "My Story",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              child: FutureBuilder(
                future: loadFriends(),
                builder: (ctx, snapsot) {
                  return friendIds == null
                      ? const Text("")
                      : FutureBuilder(
                          future: LoadFriendStory(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return friendStoryDocument.isEmpty
                                  ? const Text("")
                                  : ListView.builder(
                                      itemCount: friendStoryDocument.length,
                                      itemBuilder: (ctx, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, bottom: 10),
                                          child: GestureDetector(
                                            child: Card(
                                              elevation: 3,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: ListTile(
                                                contentPadding: EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                leading: CircleAvatar(
                                                  radius: 35,
                                                  // backgroundImage: NetworkImage(
                                                  // friendStoryDocument[index]
                                                  //     ['imageurl'],
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                          friendStoryDocument[
                                                                  index]
                                                              ['imageurl']),

                                                  backgroundColor: Colors.grey,
                                                ),
                                                title: Text(
                                                  friendStoryDocument[index]
                                                          ['userName']
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onTap: () async {
                                              DocumentSnapshot userSnapshot =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('story')
                                                      .doc(friendStoryDocument[
                                                              index]
                                                          .id)
                                                      .get();
                                              if (userSnapshot.exists) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                    return OpenStory(
                                                        snapshot: userSnapshot);
                                                  }),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    );
                            }
                          },
                        );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
