import 'dart:async';

import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_hls_flutter_example/constants/colors.dart';
import 'package:videosdk_hls_flutter_example/screens/home_screen.dart';
import 'package:videosdk_hls_flutter_example/utils/toast.dart';
import 'package:videosdk_hls_flutter_example/widgets/common/joining/waiting_to_join.dart';
import 'package:videosdk_hls_flutter_example/widgets/Audience/audience_view.dart';
import 'package:videosdk_hls_flutter_example/widgets/host/host_view.dart';

class ILSScreen extends StatefulWidget {
  final String livestreamId, token, displayName;
  final bool micEnabled, camEnabled, chatEnabled;
  final Mode mode;
  const ILSScreen({
    Key? key,
    required this.livestreamId,
    required this.token,
    required this.displayName,
    required this.mode,
    this.micEnabled = true,
    this.camEnabled = true,
    this.chatEnabled = true,
  }) : super(key: key);

  @override
  State<ILSScreen> createState() => _ILSScreenState();
}

class _ILSScreenState extends State<ILSScreen> {
  // Livestream
  late Room livestream;
  bool _joined = false;

  Mode? localParticipantMode;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    // Create instance of Room (Livestream)
    Room room = VideoSDK.createRoom(
      roomId: widget.livestreamId,
      token: widget.token,
      displayName: widget.displayName,
      micEnabled: widget.micEnabled,
      camEnabled: widget.camEnabled,
      maxResolution: 'hd',
      multiStream: true,
      defaultCameraIndex: 1,
      mode: widget.mode,
      notification: const NotificationInfo(
        title: "Video SDK",
        message: "Video SDK is sharing screen in the Livestream",
        icon: "notification_share", // drawable icon name
      ),
    );

    localParticipantMode = widget.mode;

    // Register livesrteam events
    registerLivestreamEvents(room);

    // Join Livestream
    room.join();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: _joined
          ? SafeArea(
              child: Scaffold(
                  backgroundColor: Theme.of(context).primaryColor,
                  body: localParticipantMode == Mode.SEND_AND_RECV
                      ? HostView(livestream: livestream, token: widget.token)
                      : AudienceView(
                          livestream: livestream, token: widget.token)))
          : const WaitingToJoin(),
    );
  }

  void registerLivestreamEvents(Room _livestream) {
    // Called when joined in Livestream
    _livestream.on(
      Events.roomJoined,
      () {
        if (widget.mode == Mode.SEND_AND_RECV) {
          _livestream.localParticipant.pin();
        }
        setState(() {
          livestream = _livestream;
          localParticipantMode = _livestream.localParticipant.mode;
          _joined = true;
        });
        registerModeListener(_livestream);
      },
    );

    _livestream.on(Events.participantModeChanged, (Map<String, dynamic> data) {
      if (data['participantId'] == _livestream.localParticipant.id) {
        if (_livestream.localParticipant.mode == Mode.SEND_AND_RECV) {
          livestream.localParticipant.pin();
        } else {
          livestream.localParticipant.unpin();
        }
        setState(() {
          localParticipantMode = _livestream.localParticipant.mode;
        });
      }
    });

    // Called when livestream is ended
    _livestream.on(Events.roomLeft, (String? errorMsg) {
      if (errorMsg != null) {
        showSnackBarMessage(
            message: "Livestream left due to $errorMsg !!", context: context);
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    });

    _livestream.on(
        Events.error,
        (error) => {
              showSnackBarMessage(
                  message: "${error['name']} :: ${error['message']}",
                  context: context)
            });
  }

  void registerModeListener(Room _livestream) async {
    PubSubMessages messages = await _livestream.pubSub
        .subscribe("CHANGE_MODE_${_livestream.localParticipant.id}",
            (PubSubMessage pubSubMessage) {
      String message = pubSubMessage.message;
      if (mounted) {
        if (message == "SEND_AND_RECV") {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text(
                      "${pubSubMessage.senderName} requested to join as a speaker"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: black750,
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: black600,
                        child: const Text("Decline",
                            style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: purple,
                        child: const Text("Accept",
                            style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          _livestream.changeMode(Mode.SEND_AND_RECV);
                          Navigator.pop(context);
                        }),
                  ],
                );
              });
        } else if (message == "RECV_ONLY") {
          _livestream.changeMode(Mode.RECV_ONLY);
        }
      }
    });
  }

  Future<bool> _onWillPopScope() async {
    livestream.leave();
    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
