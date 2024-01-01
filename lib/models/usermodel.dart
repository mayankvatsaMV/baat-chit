import 'package:flutter/material.dart';

class UserModel {
  UserModel({
    required this.email,
    required this.imgUrl,
    required this.username,
  });

  String email;
  String imgUrl;
  String username;

  // Convert the UserModel object to a Map<String, dynamic> for serialization.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'imgUrl': imgUrl,
      'username': username,
    };
  }

  // Create a UserModel object from a Map<String, dynamic> for deserialization.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String,
      imgUrl: json['imgUrl'] as String,
      username: json['username'] as String,
    );
  }
}
