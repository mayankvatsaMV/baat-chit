import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({required this.specificUserId});
  String specificUserId;
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? name;

  String? bio;

  String? email;

  String? imageurl;

  Future<void> loaddetails() async {
    print("specific user id should be " + widget.specificUserId);
    var instance = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.specificUserId)
        .get();
    name = instance['username'].toString().toUpperCase();
    bio = instance['bio'].toString();
    email = instance['email'].toString();
    imageurl = instance['imageurl'].toString();
    print(imageurl);
    print(name);
    print(bio);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: FutureBuilder(
        future: loaddetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            //  return Container(
            //   width: double.infinity,
            //   height: double.infinity,
            //   child: Column(
            //     children: [
            //       Expanded(
            //         child: SizedBox(
            //           height: 50,
            //         ),
            //       ),
            //       Expanded(
            //         flex: 2,
            //         child: CircleAvatar(
            //           radius: 100,
            //           backgroundImage: CachedNetworkImageProvider(imageurl!),
            //         ),
            //       ),
            //       SizedBox(
            //         height: 40,
            //       ),
            //       Text(name!,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
            //       Text(email!,style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal )),
            //       Expanded(
            //         child: SizedBox(
            //           height: 20,
            //         ),
            //       ),
            //       Divider(
            //         thickness: 4,
            //       ),
            //       Text('Bio'),
            //       Expanded(
            //         child: Text(bio!),
            //       ),
            //       Expanded(
            //         child: SizedBox(
            //           height: 20,
            //         ),
            //       ),
            //     ],
            //   ),
            // );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundImage:
                              CachedNetworkImageProvider(imageurl!),
                        ),
                        SizedBox(height: 20),
                        Text(
                          name!,
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          email!,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.normal),
                        ),
                        SizedBox(height: 20),
                        Divider(
                          thickness: 2,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Bio',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          bio!,
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}


// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class UserProfileScreen extends StatefulWidget {
//   UserProfileScreen({required this.specificUserId});

//   final String specificUserId;

//   @override
//   State<UserProfileScreen> createState() => _UserProfileScreenState();
// }

// class _UserProfileScreenState extends State<UserProfileScreen> {
//   late String name;
//   late String bio;
//   late String email;
//   late String imageurl;

//   Future<void> loaddetails() async {
//     var instance = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.specificUserId)
//         .get();

//     setState(() {
//       name = instance['username'].toString().toUpperCase();
//       bio = instance['bio'].toString();
//       email = instance['email'].toString();
//       imageurl = instance['imageurl'].toString();
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     loaddetails();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: FutureBuilder(
//         future: loaddetails(),
//         builder: 
//       ),
//     );
//   }
// }
