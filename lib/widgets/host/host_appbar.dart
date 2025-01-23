import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_hls_flutter_example/constants/colors.dart';
import 'package:videosdk_hls_flutter_example/utils/api.dart';
import 'package:videosdk_hls_flutter_example/utils/spacer.dart';
import 'package:videosdk_hls_flutter_example/utils/toast.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:videosdk_hls_flutter_example/widgets/host/participant_list/participant_list.dart';

class HostAppBar extends StatefulWidget {
  final String token;
  final Room livestream;
  final bool isFullScreen;
  const HostAppBar(
      {Key? key,
      required this.livestream,
      required this.token,
      required this.isFullScreen})
      : super(key: key);

  @override
  State<HostAppBar> createState() => HostAppBarState();
}

class HostAppBarState extends State<HostAppBar> {
  Duration? elapsedTime;
  Timer? sessionTimer;

  Map<String, Participant> _participants = {};

  @override
  void initState() {
    startTimer();

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
                      ],
                    ),
                    // VerticalSpacer(),
                  ],
                ),
              ),
              const HorizontalSpacer(),
              TouchRippleEffect(
                borderRadius: BorderRadius.circular(12),
                rippleColor: primaryColor,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    builder: (context) =>
                        ParticipantList(livestream: widget.livestream),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: secondaryColor),
                    color: primaryColor,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/ic_participants.svg",
                        width: 22,
                        height: 22,
                        color: Colors.white,
                      ),
                      const HorizontalSpacer(4),
                      Text(_participants.length.toString()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> startTimer() async {
    dynamic session = await fetchSession(widget.token, widget.livestream.id);
    DateTime sessionStartTime = DateTime.parse(session['start']);
    final difference = DateTime.now().difference(sessionStartTime);

    setState(() {
      elapsedTime = difference;
      sessionTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            elapsedTime = Duration(
                seconds: elapsedTime != null ? elapsedTime!.inSeconds + 1 : 0);
          });
        },
      );
    });
    // log("session start time" + session.data[0].start.toString());
  }

  @override
  void dispose() {
    if (sessionTimer != null) {
      sessionTimer!.cancel();
    }
    super.dispose();
  }

  void addLivestreamListener(Room livestream) {
    livestream.on(Events.hlsStateChanged, (Map<String, dynamic> data) {
      if (mounted) {
        showSnackBarMessage(
            message:
                "Livestream HLS ${data['status'] == "HLS_STARTING" ? "is starting" : (data['status'] == "HLS_STARTED" || data['status'] == "HLS_PLAYABLE") ? "started" : data['status'] == "HLS_STOPPING" ? "is stopping" : "stopped"}",
            context: context);
      }
    });

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
