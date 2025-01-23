import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_hls_flutter_example/screens/ils_screen.dart';
import 'package:videosdk_hls_flutter_example/utils/api.dart';

import '../constants/colors.dart';
import '../utils/spacer.dart';
import '../utils/toast.dart';

// Join Screen
class AudienceJoinScreen extends StatefulWidget {
  const AudienceJoinScreen({Key? key}) : super(key: key);

  @override
  State<AudienceJoinScreen> createState() => _AudienceJoinScreenState();
}

class _AudienceJoinScreenState extends State<AudienceJoinScreen> {
  String _token = "";
  TextEditingController livestreamIdTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await fetchToken(context);
      setState(() {
        _token = token;
      });
    });
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text(
          "Join as a Auidence",
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: black750),
                      child: TextField(
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        controller: nameTextController,
                        decoration: const InputDecoration(
                            hintText: "Enter your name",
                            hintStyle: TextStyle(
                              color: textGray,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    const VerticalSpacer(16),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: black750),
                      child: TextField(
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        controller: livestreamIdTextController,
                        decoration: const InputDecoration(
                            hintText: "Enter Livestream code",
                            hintStyle: TextStyle(
                              color: textGray,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    const VerticalSpacer(16),
                    MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: purple,
                        child: const Text("Join as a Audience",
                            style: TextStyle(fontSize: 16)),
                        onPressed: () => {joinLivestream()}),
                  ],
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  Future<void> joinLivestream() async {
    if (livestreamIdTextController.text.isEmpty) {
      showSnackBarMessage(
          message: "Please enter Valid Livestream ID", context: context);
      return;
    }

    if (nameTextController.text.isEmpty) {
      showSnackBarMessage(message: "Please enter Name", context: context);
      return;
    }
    String livestreamId = livestreamIdTextController.text;
    String name = nameTextController.text;
    var validLivestream = await validateLivestream(_token, livestreamId);
    if (context.mounted) {
      if (validLivestream) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ILSScreen(
              token: _token,
              livestreamId: livestreamId,
              displayName: name,
              micEnabled: false,
              camEnabled: false,
              mode: Mode.RECV_ONLY,
            ),
          ),
        );
      } else {
        showSnackBarMessage(message: "Invalid Livestream ID", context: context);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
