import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:baatchit/screens/newfriendscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:http/http.dart' as http;

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key, required this.specificUserId}) : super(key: key);
  final String specificUserId;

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser!;
  bool isTyping = false;
  bool showTyping = false;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    print('specific user id is ' + widget.specificUserId);
    print('current  user id is ' + currentuser!.uid);

    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isMounted) {
        checkTypingStatus();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _messageController.dispose();
    super.dispose();
  }

  Future<void> SendPushNotification() async {
    try {
      var userinstance = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.specificUserId)
          .get();
      var currentuserinstance = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentuser!.uid)
          .get();
      final body = {
        'to': userinstance['pushtoken'],
        'notification': {
          'title': currentuserinstance['username'].toString().toUpperCase(),
          'body': _messageController.text,
          'android_channel_id': "chats"
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        },
      };
      var response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    ""
              },
              body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      print(await http.read(Uri.https('example.com', 'foobar.txt')));
    } catch (e) {
      // print("got $e error");
    }
  }

  void _updateTypingStatus(bool isTyping) async {
    if (_isMounted) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .update({'sendingTo': widget.specificUserId, 'isTyping': isTyping});
    }
  }

  void checkTypingStatus() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.specificUserId)
        .get();
    if (_isMounted) {
      if (userSnapshot.exists &&
          userSnapshot.get("sendingTo") == _currentUser.uid &&
          userSnapshot.get("isTyping")) {
        setState(() {
          showTyping = true;
        });
      } else {
        setState(() {
          showTyping = false;
        });
      }
    }
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    _messageController.clear();

    // Send message
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .get();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.specificUserId)
        .update({
      'pendingmessage': FieldValue.arrayUnion([currentuser!.uid])
    });
    print('specific user id is ' + widget.specificUserId);
    print('current  user id is ' + currentuser!.uid);
    _updateTypingStatus(false);
    await FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': _currentUser.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['imageurl'],
      'convBet': [widget.specificUserId, _currentUser.uid]
    }).then((value) => SendPushNotification());

    // Reset typing status after sending message
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 1, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (showTyping)
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: JumpingDots(
                    color: Colors.blue,
                    numberOfDots: 4,
                    radius: 6,
                    verticalOffset: 6,
                  ),
                )
              : const SizedBox.shrink(),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.photo),
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Type Message",
                  ),
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: false,
                  enableSuggestions: true,
                  onChanged: (text) {
                    isTyping = _messageController.text.isNotEmpty;
                    if (_isMounted) {
                      _updateTypingStatus(isTyping);
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mic),
              ),
              IconButton(
                onPressed: _submitMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
