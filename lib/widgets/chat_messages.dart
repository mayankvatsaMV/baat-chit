import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'message_bubble.dart';

class ChatMessages extends StatefulWidget {
  ChatMessages({
    Key? key,
    required this.specificUserId,
  }) : super(key: key);

  final String specificUserId;
  // ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0).createScrollPosition(Ph, context, oldPosition);

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages>
    with AutomaticKeepAliveClientMixin<ChatMessages> {
  @override
  bool get wantKeepAlive => true;
  void _showDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dialog Title'),
          content: Text('Do you want to delete this?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deleteMessage(messageId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(String messageId) {
    FirebaseFirestore.instance.collection('chat').doc(messageId).delete();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
    
          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages found.'),
            );
          }
    
          if (chatSnapshots.hasError) {
            return const Center(
              child: Text('Something went wrong...'),
            );
          }
    
          final loadedMessages = chatSnapshots.data!.docs;
          List<QueryDocumentSnapshot<Map<String, dynamic>>> newLoadedMessage =
              [];
    
          for (int i = 0; i < loadedMessages.length; i++) {
            if (loadedMessages[i]
                    .data()['convBet']
                    .contains(widget.specificUserId) &&
                loadedMessages[i]
                    .data()['convBet']
                    .contains(FirebaseAuth.instance.currentUser!.uid)) {
              // print(loadedMessages[i].data()["userId"]);
              newLoadedMessage.add(loadedMessages[i]);
            }
          }
    
          return ListView.builder(
            scrollDirection: Axis.vertical,
            primary: true,
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: newLoadedMessage.length,
            itemBuilder: (ctx, index) {
              final chatMessage = newLoadedMessage[index].data();
              final nextChatMessage = index + 1 < newLoadedMessage.length
                  ? newLoadedMessage[index + 1].data()
                  : null;
    
              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              final nextUserIsSame =
                  nextMessageUserId == currentMessageUserId;
    
              if (nextUserIsSame) {
                return GestureDetector(
                  onLongPress: () {
                    if (newLoadedMessage[index].data()['userId'] ==
                        FirebaseAuth.instance.currentUser!.uid)
                      _showDialog(context, newLoadedMessage[index].id);
                  },
                  child: MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId,
                  ),
                );
              } else {
                return GestureDetector(
                  onLongPress: () {
                    if (newLoadedMessage[index].data()['userId'] ==
                        FirebaseAuth.instance.currentUser!.uid)
                      _showDialog(context, newLoadedMessage[index].id);
                  },
                  child: MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
