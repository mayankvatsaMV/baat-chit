import 'dart:io';
import 'package:baatchit/screens/myprofilescreen.dart';
import 'package:baatchit/screens/storyscreen.dart';
import 'package:baatchit/widgets/alluserswidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'newfriendscreen.dart';

final _firebase = FirebaseAuth.instance;

var kNameStyle = TextStyle(color: Colors.black, fontSize: 20);
var kTitleStyle = TextStyle(color: Colors.white, fontSize: 25);

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground, set isonline to true
      setOnlineStatus(true);
    } else if (state == AppLifecycleState.paused) {
      // App is going into the background, set isonline to false
      setOnlineStatus(false);
    }
  }

  void setOnlineStatus(bool isOnline) async {
    try {
      if (_firebase.currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_firebase.currentUser!.uid)
            .update({
          'isonline': isOnline,
        });
      }
    } catch (error) {
      print('Error updating online status: $error');
    }
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'Baat Chit',
            style: kTitleStyle,
          ),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Colors.green,
            unselectedLabelColor: const Color.fromARGB(255, 255, 255, 255),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Chat'),
              Tab(text: 'Story'),
              Tab(text: 'Find Friend'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_firebase.currentUser!.uid)
                    .update({'pushtoken': ""});
                    ZegoUIKitPrebuiltCallInvitationService().uninit();
                _firebase.signOut();
              },
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            AllUserWidget(),
            Storyscreen(),
            NewFriendScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx){
              return MyProfileScreen(); 
            }));
          },
          child: const Icon(Icons.person_3_rounded),
        ),
      ),
    );
  }
}
