import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// A MessageBubble for showing a single chat message on the ChatScreen.
class MessageBubble extends StatefulWidget {
  // Create a message bubble which is meant to be the first in the sequence.
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  // Create a amessage bubble that continues the sequence.
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  // Whether or not this message bubble is the first in a sequence of messages
  // from the same user.
  // Modifies the message bubble slightly for these different cases - only
  // shows user image for the first message from the same user, and changes
  // the shape of the bubble for messages thereafter.
  final bool isFirstInSequence;

  // Image of the user to be displayed next to the bubble.
  // Not required if the message is not the first in a sequence.
  final String? userImage;

  // Username of the user.
  // Not required if the message is not the first in a sequence.
  final String? username;
  final String message;

  // Controls how the MessageBubble will be aligned.
  final bool isMe;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isLoading = true;
  late Future<void> _imageLoading;
  @override
  // void initState()  {
  //   // TODO: implement initState
  //   super.initState();
  //    NetworkImage(widget.userImage!);
  // }
  // void initState() {
  //   super.initState();
  //   // Load the image here
  //   if (widget.userImage != null) {
  //     _imageLoading = precacheImage(NetworkImage(widget.userImage!), context)
  //         .then((value) => setState(() {
  //               _isLoading = false;
  //             }));
  //   }
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Move the precacheImage logic here
  //   if (widget.userImage != null && _imageLoading == null) {
  //     _imageLoading = precacheImage(NetworkImage(widget.userImage!), context)
  //         .then((value) => setState(() {
  //               _isLoading = false;
  //             }));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        if (widget.userImage != null)
          Positioned(
            top: 15,
            // Align user image to the right, if the message is from me.
            right: widget.isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                widget.userImage!,
              ),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 23,
            ),
            // child: CircleAvatar(
            //   backgroundColor: theme.colorScheme.primary.withAlpha(180),
            //   radius: 23,
            //   child: FutureBuilder(
            //     future: _imageLoading,
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.done) {
            //         // Image has been loaded
            //         return ClipOval(
            //           child: Image.network(
            //             widget.userImage!,
            //             width: 46,
            //             height: 46,
            //             fit: BoxFit.cover,
            //           ),
            //         );
            //       } else {
            //         // Image is still loading, show a CircularProgressIndicator
            //         return Center(
            //           child: CircularProgressIndicator(
            //             color: Colors.red,
            //           ),
            //         );
            //       }
            //     },
            //   ),
            // ),
          ),
        Container(
          // Add some margin to the edges of the messages, to allow space for the
          // user's image.
          margin: const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            // The side of the chat screen the message should show at.
            mainAxisAlignment:
                widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: widget.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // First messages in the sequence provide a visual buffer at
                  // the top.
                  if (widget.isFirstInSequence) const SizedBox(height: 18),
                  if (widget.username != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 13,
                        right: 13,
                      ),
                      child: Text(
                        widget.username!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                  // The "speech" box surrounding the message.
                  Container(
                    decoration: BoxDecoration(
                      color: widget.isMe
                          ? Theme.of(context).colorScheme.primary.withAlpha(200)
                          : theme.colorScheme.secondary.withAlpha(200),
                      // Only show the message bubble's "speaking edge" if first in
                      // the chain.
                      // Whether the "speaking edge" is on the left or right depends
                      // on whether or not the message bubble is the current user.
                      borderRadius: BorderRadius.only(
                        topLeft: !widget.isMe && widget.isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        topRight: widget.isMe && widget.isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    // Set some reasonable constraints on the width of the
                    // message bubble so it can adjust to the amount of text
                    // it should show.
                    constraints: const BoxConstraints(maxWidth: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    // Margin around the bubble.
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        // Add a little line spacing to make the text look nicer
                        // when multilined.
                        height: 1.3,
                        color: widget.isMe
                            ? Colors.black87
                            : theme.colorScheme.onSecondary,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
