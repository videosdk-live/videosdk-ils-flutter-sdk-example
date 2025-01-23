import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_hls_flutter_example/widgets/host/grid/participant_grid_tile.dart';

class ParticipantTile extends StatefulWidget {
  final Room room;
  final Orientation orientation;
  const ParticipantTile(
      {Key? key, required this.room, required this.orientation})
      : super(key: key);

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  late Participant localParticipant;
  String? activeSpeakerId;
  String? presenterId;
  int numberofColumns = 1;
  int numberOfMaxOnScreenParticipants = 6;
  String quality = "high";

  Map<String, Participant> participants = {};
  Map<String, Participant> onScreenParticipants = {};

  @override
  void initState() {
    localParticipant = widget.room.localParticipant;
    participants.putIfAbsent(localParticipant.id, () => localParticipant);
    participants.addAll(widget.room.participants);
    presenterId = widget.room.activePresenterId;
    numberOfMaxOnScreenParticipants = presenterId != null ? 2 : 6;
    updateOnScreenParticipants();
    // Setting livestream event listeners
    setLivestreamEventListener(widget.room);

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
    return Flex(
      direction: widget.orientation == Orientation.portrait
          ? Axis.vertical
          : Axis.horizontal,
      children: [
        for (int i = 0;
            i < (onScreenParticipants.length / numberofColumns).ceil();
            i++)
          Flexible(
              child: Flex(
            direction: widget.orientation == Orientation.portrait
                ? Axis.horizontal
                : numberofColumns == 1
                    ? Axis.horizontal
                    : Axis.vertical,
            children: [
              for (int j = 0;
                  j <
                      onScreenParticipants.values
                          .toList()
                          .sublist(
                              i * numberofColumns,
                              (i + 1) * numberofColumns >
                                      onScreenParticipants.length
                                  ? onScreenParticipants.length
                                  : (i + 1) * numberofColumns)
                          .length;
                  j++)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ParticipantGridTile(
                        key: Key(onScreenParticipants.values
                            .toList()
                            .sublist(
                                i * numberofColumns,
                                (i + 1) * numberofColumns >
                                        onScreenParticipants.length
                                    ? onScreenParticipants.length
                                    : (i + 1) * numberofColumns)
                            .elementAt(j)
                            .id),
                        participant: onScreenParticipants.values
                            .toList()
                            .sublist(
                                i * numberofColumns,
                                (i + 1) * numberofColumns >
                                        onScreenParticipants.length
                                    ? onScreenParticipants.length
                                    : (i + 1) * numberofColumns)
                            .elementAt(j),
                        activeSpeakerId: activeSpeakerId,
                        quality: quality),
                  ),
                )
            ],
          )),
      ],
    );
  }

  void setLivestreamEventListener(Room livestream) {
    // Called when participant joined livestream
    livestream.on(
      Events.participantJoined,
      (Participant participant) {
        final newParticipants = participants;
        newParticipants[participant.id] = participant;
        setState(() {
          participants = newParticipants;
          updateOnScreenParticipants();
        });
      },
    );

    // Called when participant left livestream
    livestream.on(
      Events.participantLeft,
      (participantId) {
        final newParticipants = participants;

        newParticipants.remove(participantId);
        setState(() {
          participants = newParticipants;
          updateOnScreenParticipants();
        });
      },
    );

    livestream.on(
      Events.speakerChanged,
      (_activeSpeakerId) {
        setState(() {
          activeSpeakerId = _activeSpeakerId;
          updateOnScreenParticipants();
        });
      },
    );

    livestream.on(
      Events.participantModeChanged,
      (data) {
        Map<String, Participant> _participants = {};
        Participant _localParticipant = widget.room.localParticipant;
        _participants.putIfAbsent(
            _localParticipant.id, () => _localParticipant);
        _participants.addAll(livestream.participants);
        // log("List Mode Change mode:: ${_participants[data['participantId']]?.mode.name}");

        setState(() {
          localParticipant = _localParticipant;
          participants = _participants;
          updateOnScreenParticipants();
        });
      },
    );

    livestream.on(Events.presenterChanged, (_presenterId) {
      setState(() {
        presenterId = _presenterId;
        numberOfMaxOnScreenParticipants = _presenterId != null ? 2 : 6;
        updateOnScreenParticipants();
      });
    });

    livestream.localParticipant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == "share") {
        setState(() {
          numberOfMaxOnScreenParticipants = 2;
          updateOnScreenParticipants();
        });
      }
    });
    livestream.localParticipant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == "share") {
        setState(() {
          numberOfMaxOnScreenParticipants = 6;
          updateOnScreenParticipants();
        });
      }
    });
  }

  updateOnScreenParticipants() {
    Map<String, Participant> newScreenParticipants = <String, Participant>{};
    List<Participant> conferenceParticipants = participants.values
        .where((element) => element.mode == Mode.SEND_AND_RECV)
        .toList();

    conferenceParticipants
        .sublist(
            0,
            conferenceParticipants.length > numberOfMaxOnScreenParticipants
                ? numberOfMaxOnScreenParticipants
                : conferenceParticipants.length)
        .forEach((participant) {
      newScreenParticipants.putIfAbsent(participant.id, () => participant);
    });
    if (!newScreenParticipants.containsKey(activeSpeakerId) &&
        activeSpeakerId != null) {
      newScreenParticipants.remove(newScreenParticipants.keys.last);
      newScreenParticipants.putIfAbsent(
          activeSpeakerId!,
          () => participants.values
              .firstWhere((element) => element.id == activeSpeakerId));
    }
    if (!listEquals(newScreenParticipants.keys.toList(),
        onScreenParticipants.keys.toList())) {
      setState(() {
        onScreenParticipants = newScreenParticipants;
        quality = newScreenParticipants.length > 4
            ? "low"
            : newScreenParticipants.length > 2
                ? "medium"
                : "high";
      });
    }
    if (numberofColumns !=
        (newScreenParticipants.length > 2 ||
                numberOfMaxOnScreenParticipants == 2
            ? 2
            : 1)) {
      setState(() {
        numberofColumns = newScreenParticipants.length > 2 ||
                numberOfMaxOnScreenParticipants == 2
            ? 2
            : 1;
      });
    }
  }
}
