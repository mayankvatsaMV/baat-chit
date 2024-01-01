import 'package:baatchit/firebaseapi.dart';
import 'package:baatchit/main.dart';
import 'package:baatchit/screens/newfriendscreen.dart';
import 'package:baatchit/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/widgets.dart'; // Add this import statement
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  AuthScreen({required this.token, required this.onSignUp});
  String token;
   Function(bool cond)onSignUp;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formkey = GlobalKey<FormState>();
  String _enteredEmail = "";
  String _enteredPassword = "";
  String _enteredUsername = '';
  var _visibility = false;
  var _isLogIn = true;
  File? _selectedImage;
  bool _isAuthenticating = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is going into the background, update last online time
      updateLastOnlineTime();
    }
  }

  Future<void> updateLastOnlineTime() async {
    try {
      if (_firebase.currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_firebase.currentUser!.uid)
            .update({
          'lastonline': FieldValue.serverTimestamp(),
          'isonline': false,
        });
      }
    } catch (error) {
      print('Error updating last online time: $error');
    }
  }

  void _submit() async {
    final isValid = _formkey.currentState!.validate();
    if (!isValid || (!_isLogIn && _selectedImage == null)) {
      if (isValid) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please Select the Image')));
      }
      return;
    }
    _formkey.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      // String pushToken = FirebaseApi().getPushToken();
      if (_isLogIn) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        print(userCredentials);
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .update({
          'pushtoken': token,
        });
        widget.onSignUp(false);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final Storageref = FirebaseStorage.instance
            .ref()
            .child(
              'user_images',
            )
            .child(
              '${userCredentials.user!.uid}.jpg',
            );

        await Storageref.putFile(_selectedImage!);
        final imageUrl = await Storageref.getDownloadURL();
        print(imageUrl);
        var querySnapshot =
            await FirebaseFirestore.instance.collection('users').get();
        var numberofusers = querySnapshot.size;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'password': _enteredPassword,
          'imageurl': imageUrl,
          'isTyping': false,
          'sendingTo': "",
          "friends": [],
          'gender': "",
          'bio': "",
          'isonline': false,
          'lastonline': "",
          'pendingmessage': [],
          'UniqueId': numberofusers + 1,
          // 'pushtoken': pushToken
        });
        widget.onSignUp(true);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Aunthetication Failed')));
      }
      setState(() {
        _isAuthenticating = false;
      });

      print(_enteredEmail);
      print(_enteredPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, right: 20, left: 20),
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ),
              Card(
                // color: Colors.red,
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogIn)
                            UserImagePicker(onPickImage: (pickedImage) {
                              _selectedImage = pickedImage;
                            }),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@")) {
                                return "Please enter a valid Email address";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // print("printed email is "+ _enteredEmail);
                              _enteredEmail = value!;
                            },
                          ),
                          if (!_isLogIn)
                            TextFormField(
                              decoration: const InputDecoration(
                                  label: Text("Username")),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null || value.trim().length < 1) {
                                  return 'Please Enter A Username';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          TextFormField(
                            decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _visibility = !_visibility;
                                  });
                                },
                                child: _visibility
                                    ? Icon(Icons.visibility)
                                    : Icon(Icons.visibility_off),
                              ),
                              labelText: 'Password',
                            ),
                            obscureText: !_visibility,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be atleast 6 character long';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: () {
                                _submit();
                              },
                              child: Text(_isLogIn ? "Login" : "Signup"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogIn = !_isLogIn;
                                });
                              },
                              child: Text(_isLogIn
                                  ? "Create An Account"
                                  : "I already have an account"),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



// void _submit() async {
  //   final isValid = _formkey.currentState!.validate();
  //   if (!isValid || (!_isLogIn && _selectedImage == null)) {
  //     if (isValid) {
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Please Select the Image')));
  //     }
  //     return;
  //   }
  //   _formkey.currentState!.save();
  //   try {
  //     if (_isLogIn) {
  //       final userCredentials = await _firebase.signInWithEmailAndPassword(
  //           email: _enteredEmail, password: _enteredPassword);

  //       if (userCredentials.user?.emailVerified == true) {
  //         // The email is verified, proceed with sign-in
  //         print('Email is verified. Signing in...');
  //       } else {
  //         // The email is not verified, display a message or take appropriate action
  //         print('Email is not verified. Please verify your email.');
  //       }

  //       print(userCredentials);
  //     } else {
  //       final userCredentials = await _firebase.createUserWithEmailAndPassword(
  //           email: _enteredEmail, password: _enteredPassword);

  //       // Send email verification
  //       await userCredentials.user?.sendEmailVerification();

  //       // Display a message to check the email for verification
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Verification email sent. Please check your email.'),
  //         ),
  //       );

  //       // Check if the email is verified for the newly created user
  //       if (userCredentials.user?.emailVerified == true) {
  //         // The email is verified, proceed with further actions
  //         print('Email is verified. Continue with the signup process...');
  //       } else {
  //         // The email is not verified, display a message or take appropriate action
  //         print('Email is not verified. Please verify your email.');
  //       }
  //     }
  //   } on FirebaseAuthException catch (error) {
  //     if (error.code == 'email-already-in-use') {
  //       ScaffoldMessenger.of(context).clearSnackBars();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text(error.message ?? 'Authentication Failed')));
  //     }

      // print(_enteredEmail);
  //     print(_enteredPassword);
  //   }
  // }