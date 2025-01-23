import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_hls_flutter_example/constants/colors.dart';
import 'package:videosdk_hls_flutter_example/utils/toast.dart';
import 'package:videosdk_hls_flutter_example/widgets/host/host_action_bar.dart';
import 'package:videosdk_hls_flutter_example/widgets/host/grid/participant_grid.dart';
import 'package:videosdk_hls_flutter_example/widgets/host/screenshare_view.dart';

import 'package:videosdk_hls_flutter_example/widgets/host/host_appbar.dart';
import 'package:videosdk_hls_flutter_example/widgets/common/chat/chat_view.dart';

class HostView extends StatefulWidget {
  final Room livestream;
  final String token;
  const HostView({super.key, required this.livestream, required this.token});

  @override
  State<HostView> createState() => _SpeakerViewState();
}

class _SpeakerViewState extends State<HostView> {
  bool showChatSnackbar = true;
  var containerKey = GlobalKey();
  var tapPosition = const Offset(0, 0);
  // Streams
  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;
  Stream? remoteParticipantShareStream;

  bool fullScreen = false;

  @override
  void initState() {
    super.initState();
    // Register Livestream events
    registerLivestreamEvents(widget.livestream);
    subscribeToChatMessages(widget.livestream);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Size get sizeQuery {
    return MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    final statusbarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          HostAppBar(
            livestream: widget.livestream,
            token: widget.token,
            isFullScreen: fullScreen,
          ),
          Expanded(
            child: GestureDetector(
              onDoubleTap: () => {
                setState(() {
                  fullScreen = !fullScreen;
                })
              },
              child: OrientationBuilder(
                builder: (context, orientation) {
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
                },
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: !fullScreen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: const SizedBox.shrink(),
            firstChild: HostActionBar(
              isMicEnabled: audioStream != null,
              isCamEnabled: videoStream != null,
              isScreenShareEnabled: shareStream != null,
              // Called when Call End button is pressed
              onCallEndButtonPressed: () {
                widget.livestream.end();
              },

              onCallLeaveButtonPressed: () {
                widget.livestream.leave();
              },
              // Called when mic button is pressed
              onMicButtonPressed: () {
                if (audioStream != null) {
                  widget.livestream.muteMic();
                } else {
                  widget.livestream.unmuteMic();
                }
              },
              // Called when camera button is pressed
              onCameraButtonPressed: () {
                if (videoStream != null) {
                  widget.livestream.disableCam();
                } else {
                  widget.livestream.enableCam();
                }
              },

              onSwitchMicButtonPressed: (details) async {
                List<AudioDeviceInfo>? outptuDevice =
                    await VideoSDK.getAudioDevices();
                double bottomMargin = (70.0 * outptuDevice!.length);
                final screenSize = MediaQuery.of(context).size;
                await showMenu(
                  context: context,
                  color: black700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  position: RelativeRect.fromLTRB(
                    screenSize.width - details.globalPosition.dx,
                    details.globalPosition.dy - bottomMargin,
                    details.globalPosition.dx + 50,
                    (bottomMargin),
                  ),
                  items: outptuDevice.map((e) {
                    return PopupMenuItem(value: e, child: Text(e.label));
                  }).toList(),
                  elevation: 8.0,
                ).then((value) {
                  if (value != null) {
                    widget.livestream.switchAudioDevice(value);
                  }
                });
              },

              onSwitchCameraButtonPressed: (details) async {
                List<VideoDeviceInfo>? outptuDevice =
                    await VideoSDK.getVideoDevices();
                double bottomMargin = (70.0 * outptuDevice!.length);
                final screenSize = MediaQuery.of(context).size;
                await showMenu(
                  context: context,
                  color: black700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  position: RelativeRect.fromLTRB(
                    screenSize.width - details.globalPosition.dx,
                    details.globalPosition.dy - bottomMargin,
                    details.globalPosition.dx,
                    (bottomMargin),
                  ),
                  items: outptuDevice.map((e) {
                    return PopupMenuItem(value: e, child: Text(e.label));
                  }).toList(),
                  elevation: 8.0,
                ).then((value) {
                  if (value != null) {
                    widget.livestream.changeCam(value);
                  }
                });
              },

              onChatButtonPressed: () {
                setState(() {
                  showChatSnackbar = false;
                });
                showModalBottomSheet(
                  context: context,
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height -
                          statusbarHeight -
                          32),
                  isScrollControlled: true,
                  builder: (context) => ChatView(
                    key: const Key("ChatScreen"),
                    livestream: widget.livestream,
                    showClose: true,
                    orientation: Orientation.portrait,
                    onClose: () {
                      Navigator.pop(context);
                    },
                  ),
                ).whenComplete(() {
                  setState(() {
                    showChatSnackbar = true;
                  });
                });
              },

              // Called when more options button is pressed
              onScreenShareButtonPressed: () {
                if (remoteParticipantShareStream == null) {
                  if (shareStream == null) {
                    widget.livestream.enableScreenShare();
                  } else {
                    widget.livestream.disableScreenShare();
                  }
                } else {
                  showSnackBarMessage(
                      message: "Someone is already presenting",
                      context: context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void registerLivestreamEvents(Room _livestream) {
    // Called when stream is enabled
    _livestream.localParticipant.on(Events.streamEnabled, (Stream _stream) {
      if (_stream.kind == 'video') {
        setState(() {
          videoStream = _stream;
        });
      } else if (_stream.kind == 'audio') {
        setState(() {
          audioStream = _stream;
        });
      } else if (_stream.kind == 'share') {
        setState(() {
          shareStream = _stream;
        });
      }
    });

    // Called when stream is disabled
    _livestream.localParticipant.on(Events.streamDisabled, (Stream _stream) {
      if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
        setState(() {
          videoStream = null;
        });
      } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
        setState(() {
          audioStream = null;
        });
      } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
        setState(() {
          shareStream = null;
        });
      }
    });

    // Called when presenter is changed
    _livestream.on(Events.presenterChanged, (_activePresenterId) {
      Participant? activePresenterParticipant =
          _livestream.participants[_activePresenterId];

      // Get Share Stream
      Stream? _stream = activePresenterParticipant?.streams.values
          .singleWhere((e) => e.kind == "share");

      setState(() => remoteParticipantShareStream = _stream);
    });

    _livestream.on(
        Events.error,
        (error) => {
              if (mounted)
                {
                  showSnackBarMessage(
                      message: error['name'].toString() +
                          " :: " +
                          error['message'].toString(),
                      context: context)
                }
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

    livestream.pubSub.subscribe("RAISE_HAND", (message) {
      if (message.senderId != livestream.localParticipant.id) {
        if (mounted) {
          if (showChatSnackbar) {
            showSnackBarMessage(
                icon: SvgPicture.asset(
                  "assets/ic_hand.svg",
                  color: Colors.black,
                ),
                message: message.senderName + " raised hand ",
                context: context);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
