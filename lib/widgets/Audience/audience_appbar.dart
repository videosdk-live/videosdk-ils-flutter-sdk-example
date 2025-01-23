import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_hls_flutter_example/utils/spacer.dart';

import 'package:videosdk_hls_flutter_example/utils/toast.dart';

class AudienceAppBar extends StatefulWidget {
  final String token;
  final Room livestream;
  final bool isFullScreen;
  const AudienceAppBar(
      {Key? key,
      required this.livestream,
      required this.token,
      required this.isFullScreen})
      : super(key: key);

  @override
  State<AudienceAppBar> createState() => AudienceAppBarState();
}

class AudienceAppBarState extends State<AudienceAppBar> {
  Duration? elapsedTime;
  Timer? sessionTimer;

  Map<String, Participant> _participants = {};

  @override
  void initState() {
    _participants.putIfAbsent(widget.livestream.localParticipant.id,
        () => widget.livestream.localParticipant);
    _participants.addAll(widget.livestream.participants);

    addLivestreamListener(widget.livestream);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  double width = 160.0;
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState: !widget.isFullScreen
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        secondChild: const SizedBox.shrink(),
        firstChild: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.livestream.id,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                            child: Icon(
                              Icons.copy,
                              size: 16,
                            ),
                          ),
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: widget.livestream.id));
                            showSnackBarMessage(
                                message: "Livestream ID has been copied.",
                                context: context);
                          },
                        ),
                        HorizontalSpacer(width),
                        ElevatedButton(
                            onPressed: () {
                              widget.livestream.leave();
                            },
                            child: const Icon(
                              Icons.call_end,
                              color: Colors.red,
                            ))
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    if (sessionTimer != null) {
      sessionTimer!.cancel();
    }
    super.dispose();
  }

  void addLivestreamListener(Room livestream) {
    livestream.on(Events.hlsStateChanged, (Map<String, dynamic> data) {});

    livestream.on(Events.participantJoined, (participant) {
      if (mounted) {
        final newParticipants = _participants;
        newParticipants[participant.id] = participant;
        setState(() => _participants = newParticipants);
      }
    });

    livestream.on(Events.participantLeft, (participantId) {
      if (mounted) {
        final newParticipants = _participants;
        newParticipants.remove(participantId);

        setState(() => _participants = newParticipants);
      }
    });
  }
}
