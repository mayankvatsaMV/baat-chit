import 'package:baatchit/screens/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

final _firebase = FirebaseAuth.instance;

class AllUserWidget extends StatefulWidget {
  @override
  State<AllUserWidget> createState() => _AllUserWidgetState();
}

class _AllUserWidgetState extends State<AllUserWidget> {
  List<dynamic> checkNewmessageIndicator = [];

  Future<void> ChatOpened(String specificUserId) async {
    var currentuserinstance = await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebase.currentUser!.uid)
        .get();
    List<dynamic> pendingmessage = currentuserinstance['pendingmessage'];
    pendingmessage.remove(specificUserId);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebase.currentUser!.uid)
        .update({'pendingmessage': pendingmessage});
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ZegoUIKitPrebuiltCallInvitationService().init(
        appID: 56210256 /*input your AppID*/,
        appSign:
            "1fa88e3c620304c62a6ad92c2e0ebc5f5c7cfc8ec17c64cf563bd6ff47778e6e" /*input your AppSign*/,
        userID: _firebase.currentUser!.uid,
        userName: "",
        plugins: [ZegoUIKitSignalingPlugin()],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Users'),
        backgroundColor: Color.fromARGB(0, 255, 255, 255),
        // Add any additional customization to the AppBar here
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No users found.'),
              );
            }

            final loadedUsers = snapshot.data!.docs;
            final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

            final filteredUsers = loadedUsers.where((user) {
              List<dynamic>? friends = user['friends'];
              return friends != null && friends.contains(currentUserUid);
            }).toList();

            for (int i = 0; i < loadedUsers.length; i++) {
              if (loadedUsers[i].id == currentUserUid) {
                checkNewmessageIndicator = loadedUsers[i]['pendingmessage'];
              }
            }
            return ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (ctx, index) {
                return GestureDetector(
                  child: Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.only(top: 5, bottom: 5, left: 5),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            const Color.fromARGB(255, 203, 203, 203),
                        // foregroundImage:
                        //     NetworkImage(filteredUsers[index]["imageurl"]),
                        foregroundImage: CachedNetworkImageProvider(
                            filteredUsers[index]["imageurl"]),
                      ),
                      title: Text(
                        filteredUsers[index]['username'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      trailing: checkNewmessageIndicator
                              .contains(filteredUsers[index].id)
                          ? Container(
                              width: 50,
                              // color: Colors.red,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                            )
                          : null,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      ChatOpened(filteredUsers[index].id);
                      return chatScreen(
                        specificUserId: filteredUsers[index].id,
                        title: filteredUsers[index].data()['username'],
                        imgUrl: filteredUsers[index].data()['imageurl'],
                        specificUniId: filteredUsers[index].data()['UniqueId'].toString(),
                      );
                    }));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
