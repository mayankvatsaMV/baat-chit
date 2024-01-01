import 'package:firebase_messaging/firebase_messaging.dart';


Future<void>handleBackgroundMessage(RemoteMessage message)async{
  print('title ${message.notification!.title}');
  print('Body ${message.notification!.body}');
  print('Payload ${message.data}');
}

class FirebaseApi{
     String? pushToken;
  final _firebaseMessaging=FirebaseMessaging.instance;
  Future<String?>initNotification()async{
    await _firebaseMessaging.requestPermission();
    final fCMToken=await _firebaseMessaging.getToken();
    print('token ' +fCMToken.toString());
    pushToken=fCMToken.toString();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    return pushToken;
  }
  String getPushToken(){
  return  pushToken!;
}
}