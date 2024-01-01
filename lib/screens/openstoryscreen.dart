import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class OpenStory extends StatefulWidget {
  OpenStory({super.key, required this.snapshot});
  final DocumentSnapshot snapshot;

  @override
  _OpenStoryState createState() => _OpenStoryState();
}

class _OpenStoryState extends State<OpenStory> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    StoryController _controller = StoryController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.snapshot['userName'].toString().toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
      ),
      body: StoryView(
          storyItems: [
            StoryItem.pageImage(
                url: widget.snapshot['imageurl'], controller: _controller),
          ],
          controller: _controller,
          onComplete: () {
            Navigator.pop(context);
          },
          onVerticalSwipeComplete: (direction) {
            if (direction == Direction.down) {
              Navigator.pop(context);
            }
          }),
    );
  }
}
