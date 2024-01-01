import 'dart:math';

import 'package:baatchit/screens/newfriendscreen.dart';
import 'package:baatchit/screens/userprofilescreen.dart';
import 'package:baatchit/widgets/call.dart';
import 'package:baatchit/widgets/chat_messages.dart';
import 'package:baatchit/widgets/new_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// ignore: camel_case_types, must_be_immutable
class chatScreen extends StatefulWidget {
  chatScreen(
      {super.key,
      required this.specificUserId,
      required this.title,
      required this.imgUrl,
      required this.specificUniId});
  String specificUserId;
  String title;
  String imgUrl;
  String specificUniId;
  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen>
    with AutomaticKeepAliveClientMixin<chatScreen> {
  @override
  bool get wantKeepAlive => true;
  String? callId;
  String? currentUniId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createCallid();
  }

  void createCallid() async {
    var temp = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    currentUniId = temp['UniqueId'].toString();
    callId =
        concatenateNumbersInAscendingOrder(widget.specificUniId, currentUniId!);
  }

  String concatenateNumbersInAscendingOrder(String num1, String num2) {
    // Convert strings to integers for comparison
    int intNum1 = int.parse(num1);
    int intNum2 = int.parse(num2);
    print(intNum1);
    print(intNum2);
    // Compare integers
    if (intNum1 < intNum2) {
      // If num1 is smaller, concatenate num1 + num2
      return num1 + num2;
    } else {
      // If num2 is smaller, concatenate num2 + num1
      return num2 + num1;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: Row(
          children: [
            // const SizedBox(
            //   width: 5,
            // ),
            Expanded(
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: CircleAvatar(
                radius: 25,
                backgroundImage: CachedNetworkImageProvider(widget.imgUrl),
              ),
            )
          ],
        ),
        leadingWidth: MediaQuery.of(context).size.width * 0.25,
        title: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return UserProfileScreen(specificUserId: widget.specificUserId);
            }));
          },
          child: Container(
            child: Text(
              widget.title,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CallPage(
                              callID: callId!,
                              userid: currentuser!.uid,
                              userName: widget.title.toUpperCase(),
                              isVideoCall: true,
                            )));
              },
              icon: Icon(
                Icons.video_call,
                color: Colors.white,
              )),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CallPage(
                              callID: callId!,
                              userid: currentuser!.uid,
                              userName: widget.title.toUpperCase(),
                              isVideoCall: false,
                            )));
              },
              icon: Icon(
                Icons.call,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(
              specificUserId: widget.specificUserId,
            ),
          ),
          NewMessage(specificUserId: widget.specificUserId),
        ],
      ),
    );
  }
}
