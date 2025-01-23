import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_hls_flutter_example/constants/colors.dart';
import 'package:videosdk_hls_flutter_example/utils/spacer.dart';

class ScreenShareView extends StatefulWidget {
  final Room livestream;
  const ScreenShareView({Key? key, required this.livestream}) : super(key: key);

  @override
  State<ScreenShareView> createState() => _ScreenShareViewState();
}

class _ScreenShareViewState extends State<ScreenShareView> {
  Participant? _presenterParticipant;
  Stream? shareStream;
  String? presenterId;
  bool isLocalScreenShare = false;

  @override
  void initState() {
    _presenterParticipant = widget.livestream.activePresenterId != null
        ? widget.livestream.participants.values.firstWhere(
            (element) => element.id == widget.livestream.activePresenterId)
        : null;

    if (widget.livestream.activePresenterId ==
        widget.livestream.localParticipant.id) {
      _presenterParticipant = widget.livestream.localParticipant;
      isLocalScreenShare = true;
    }

    presenterId = _presenterParticipant?.id;

    shareStream = _presenterParticipant?.streams.values
        .firstWhere((stream) => stream.kind == "share");
    setLivestreamListeners(widget.livestream);
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return shareStream != null
        ? Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: black800,
                ),
                child: Stack(
                  children: [
                    !isLocalScreenShare && shareStream != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: RTCVideoView(
                              shareStream?.renderer as RTCVideoRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitContain,
                            ),
                          )
                        : Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                SvgPicture.asset(
                                  "assets/ic_screen_share.svg",
                                  height: 40,
                                ),
                                const VerticalSpacer(20),
                                const Text(
                                  "You are presenting to everyone",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                const VerticalSpacer(20),
                                MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 30),
                                    color: purple,
                                    child: const Text("Stop Presenting",
                                        style: TextStyle(fontSize: 16)),
                                    onPressed: () => {
                                          widget.livestream.disableScreenShare()
                                        })
                              ])),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: black700,
                        ),
                        child: Text(isLocalScreenShare
                            ? "You are presenting"
                            : "${_presenterParticipant!.displayName} is presenting"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  void setLivestreamListeners(Room _livestream) {
    _livestream.localParticipant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == "share") {
        setState(() {
          isLocalScreenShare = true;
          shareStream = stream;
        });
      }
    });
    _livestream.localParticipant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == "share") {
        setState(() {
          isLocalScreenShare = false;
          shareStream = null;
        });
      }
    });

    _livestream.participants.forEach((key, value) {
      addParticipantListener(value);
    });
    // Called when presenter changes
    _livestream.on(Events.presenterChanged, (_presenterId) {
      Participant? presenterParticipant = _presenterId != null
          ? widget.livestream.participants.values
              .firstWhere((element) => element.id == _presenterId)
          : null;

      setState(() {
        _presenterParticipant = presenterParticipant;
        presenterId = _presenterId;
      });
    });

    _livestream.on(Events.participantJoined, (Participant participant) {
      log("${participant.displayName} JOINED");
      addParticipantListener(participant);
    });
  }

  addParticipantListener(Participant participant) {
    participant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == "share") {
        setState(() {
          shareStream = stream;
        });
      }
    });
    participant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == "share") {
        setState(() {
          shareStream = null;
        });
      }
    });
  }
}
