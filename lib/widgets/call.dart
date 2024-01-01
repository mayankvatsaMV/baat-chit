import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
class CallPage extends StatelessWidget {
  const CallPage(
      {Key? key,
      required this.callID,
      required this.userid,
      required this.userName,
      required this.isVideoCall})
      : super(key: key);
  final String callID;
  final String userid;
  final String userName;
  final bool isVideoCall;
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID:
         , // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign:
          "", // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: userid,
      userName: userName,
      callID: callID,
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config: isVideoCall == true
          ? (ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            ..onOnlySelfInRoom = (context) => Navigator.of(context).pop())
          : (ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
            ..onOnlySelfInRoom = (context) => Navigator.pop(context)),
    );
  }
}
