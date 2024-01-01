import 'dart:math';

import 'package:baatchit/firebaseapi.dart';
import 'package:baatchit/screens/authscreen.dart';
import 'package:baatchit/screens/homescreen.dart';
import 'package:baatchit/screens/splashscreen.dart';
import 'package:baatchit/screens/verifyemail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'firebase_options.dart';

String? token;
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For showing message notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats',
      visibility: NotificationVisibility.VISIBILITY_PUBLIC,
      allowBubbles: true);
  print(result);
  token = await FirebaseApi().initNotification();
  runApp(App(
    navigatorKey: navigatorKey,
  ));
}

class App extends StatefulWidget {
  App({super.key, required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  bool isSignup=false;
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      title: 'FlutterChat',
      themeMode: ThemeMode.dark,
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }
          if (snapshot.hasData){
            return isSignup==true?VerifyMail():HomeScreen();
          }
          return AuthScreen(
            onSignUp: (cond) async {
              await Future.delayed(Duration.zero); // Delay to allow setState to execute
              setState(() {
                isSignup = cond;
                print("is signup is " + cond.toString());
              });
            },
            token: token!,
          );
        // if (snapshot.hasData) {
        //     // User is logged in
        //     return HomeScreen(); // Replace HomeScreen with your actual home screen widget
        //   } else {
        //     // User is not logged in
        //     return AuthScreen(
        //       token: token!,
        //       onSignUp: () {
        //         // Navigate to VerifyEmail when signing up
        //         Navigator.of(context).pushReplacement(MaterialPageRoute(
        //           builder: (context) => VerifyMail(),
        //         ));
        //       },
        //     );
        //   }
        }
      ),
    );
  }
}
