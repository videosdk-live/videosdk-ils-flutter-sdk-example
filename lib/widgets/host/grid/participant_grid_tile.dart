import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_hls_flutter_example/constants/colors.dart';
import 'package:videosdk_hls_flutter_example/utils/spacer.dart';
import 'package:videosdk_hls_flutter_example/widgets/host/stats/call_stats.dart';

class ParticipantGridTile extends StatefulWidget {
  final Participant participant;
  final bool isLocalParticipant;
  final String? activeSpeakerId;
  final String? quality;
  const ParticipantGridTile(
      {Key? key,
      required this.participant,
      required this.quality,
      this.isLocalParticipant = false,
      required this.activeSpeakerId})
      : super(key: key);

  @override
  State<ParticipantGridTile> createState() => _ParticipantGridTileState();
}

class _ParticipantGridTileState extends State<ParticipantGridTile> {
  Stream? videoStream;
  Stream? audioStream;

  @override
  void initState() {
    _initStreamListeners();
    super.initState();

    widget.participant.streams.forEach((key, Stream stream) {
      setState(() {
        if (stream.kind == 'video') {
          videoStream = stream;
          widget.participant.setQuality(widget.quality);
        } else if (stream.kind == 'audio') {
          audioStream = stream;
        }
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: black800,
        border: widget.activeSpeakerId != null &&
                widget.activeSpeakerId == widget.participant.id
            ? Border.all(color: Colors.blueAccent)
            : null,
      ),
      child: Stack(
        children: [
          videoStream != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RTCVideoView(
                    videoStream?.renderer as RTCVideoRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                )
              : Center(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: black500,
                    ),
                    child: Text(
                      widget.participant.displayName.characters.first
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: black700.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(widget.participant.isLocal
                        ? "You"
                        : widget.participant.displayName),
                    if (audioStream == null) const HorizontalSpacer(4),
                    if (audioStream == null)
                      const Icon(
                        Icons.mic_off,
                        size: 15,
                      )
                  ],
                )),
          ),
          Positioned(
              top: 4,
              right: 4,
              child: CallStats(participant: widget.participant)),
        ],
      ),
    );
  }

  _initStreamListeners() {
    widget.participant.on(Events.streamEnabled, (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video') {
          videoStream = _stream;
          widget.participant.setQuality(widget.quality);
        } else if (_stream.kind == 'audio') {
          audioStream = _stream;
        }
      });
    });

    widget.participant.on(Events.streamDisabled, (Stream _stream) {
      setState(() {
        if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
          videoStream = null;
        } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
          audioStream = null;
        }
      });
    });

    // The SDK emits Events.streamPaused/streamResumed with either a Stream
    // (local pause/resume) or a String kind + reason (subs-manager pause/resume),
    // so both possible callback shapes must be handled here.
    widget.participant.on(Events.streamPaused, (dynamic arg0, [dynamic arg1]) {
      final stream = _resolveStream(arg0);
      if (stream == null) return;
      setState(() {
        if (stream.kind == 'video' && videoStream?.id == stream.id) {
          videoStream = null;
        } else if (stream.kind == 'audio' && audioStream?.id == stream.id) {
          audioStream = stream;
        }
      });
    });

    widget.participant.on(Events.streamResumed, (dynamic arg0, [dynamic arg1]) {
      final stream = _resolveStream(arg0);
      if (stream == null) return;
      setState(() {
        if (stream.kind == 'video' && videoStream?.id == stream.id) {
          videoStream = stream;
          widget.participant.setQuality(widget.quality);
        } else if (stream.kind == 'audio' && audioStream?.id == stream.id) {
          audioStream = stream;
        }
      });
    });
  }

  Stream? _resolveStream(dynamic arg0) {
    if (arg0 is Stream) return arg0;
    if (arg0 is String) {
      for (final stream in widget.participant.streams.values) {
        if (stream.kind == arg0) return stream;
      }
    }
    return null;
  }
}
