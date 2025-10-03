import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_hls_flutter_example/constants/colors.dart';
import 'package:videosdk_hls_flutter_example/utils/api.dart';

import 'package:videosdk_hls_flutter_example/utils/toast.dart';
import 'package:videosdk_hls_flutter_example/widgets/host/grid/participant_grid.dart';
import 'package:videosdk_hls_flutter_example/widgets/host/screenshare_view.dart';

import 'package:videosdk_hls_flutter_example/widgets/Audience/audience_appbar.dart';

class AudienceView extends StatefulWidget {
  final Room livestream;
  final String token;
  const AudienceView({
    super.key,
    required this.livestream,
    required this.token,
  });

  @override
  State<AudienceView> createState() => _AudienceViewState();
}

class _AudienceViewState extends State<AudienceView> {
  bool showChatSnackbar = true;

  bool fullScreen = false;
  late String hlsState;
  String? playbackHlsUrl;
  bool showChat = true;
  bool isEnded = false;
  bool showOverlay = true;
  int participants = 1;

  @override
  void initState() {
    super.initState();
    participants = widget.livestream.participants.length + 1;

    registerLivestreamEvents(widget.livestream);

    subscribeToChatMessages(widget.livestream);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusbarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          AudienceAppBar(
            livestream: widget.livestream,
            token: widget.token,
            isFullScreen: fullScreen,
          ),
          Expanded(
            child: GestureDetector(
                child: OrientationBuilder(builder: (context, orientation) {
              return Flex(
                direction: orientation == Orientation.portrait
                    ? Axis.vertical
                    : Axis.horizontal,
                children: [
                  ScreenShareView(livestream: widget.livestream),
                  Flexible(
                      child: ParticipantGrid(
                          livestream: widget.livestream,
                          orientation: orientation))
                ],
              );
            })),
          ),
        ],
      ),
    );
  }

  void registerLivestreamEvents(Room _livestream) {
    _livestream.on(Events.participantModeChanged, (participant) {});
    _livestream.on(Events.participantJoined, (participant) {
      setState(() {
        participants = _livestream.participants.length + 1;
      });
    });
    _livestream.on(Events.participantLeft, (participant) {
      setState(() {
        participants = _livestream.participants.length + 1;
      });
    });
    // Called when hls is started
    _livestream.on(Events.hlsStateChanged, (Map<String, dynamic> data) {
      setState(() {
        hlsState = data['status'];
      });
      if (data['status'] == "HLS_PLAYABLE") {
        setState(() {
          playbackHlsUrl = data['playbackHlsUrl'];
          isEnded = false;
          showOverlay = true;
          hideOverlay();
        });
      } else if (data['status'] == "HLS_STOPPED") {
        setState(() {
          playbackHlsUrl = null;
        });
      }
    });
    _livestream.on(
        Events.error,
        (error) => {
              showSnackBarMessage(
                  message: error['name'].toString() +
                      " :: " +
                      error['message'].toString(),
                  context: context)
            });
  }

  void subscribeToChatMessages(Room livestream) {
    livestream.pubSub.subscribe("CHAT", (message) {
      if (message.senderId != livestream.localParticipant.id) {
        if (mounted) {
          if (showChatSnackbar) {
            showSnackBarMessage(
                message: message.senderName + ": " + message.message,
                context: context);
          }
        }
      }
    });
  }

  Future<bool> isHlsPlayable(String url) async {
    int response = await fetchHls(url);
    if (response == 200) {
      return true;
    }
    return false;
  }

  void hideOverlay() {
    Timer(const Duration(seconds: 4), () {
      setState(() {
        showOverlay = false;
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
