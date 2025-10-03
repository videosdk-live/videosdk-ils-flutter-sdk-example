import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final String? _VIDEOSDK_API_ENDPOINT = "https://api.videosdk.live/v2";
Future<String> fetchToken(BuildContext context) async {
  if (!dotenv.isInitialized) {
    // Load Environment variables
    await dotenv.load(fileName: ".env");
  }
  //final String? _AUTH_URL = dotenv.env['AUTH_URL'];
  String? _AUTH_TOKEN = dotenv.env['AUTH_TOKEN'];

  return _AUTH_TOKEN ?? "";
}

Future<String> createLiveStream(String _token) async {
  final Uri getLivestreamIdUrl = Uri.parse('$_VIDEOSDK_API_ENDPOINT/rooms');
  final http.Response livestreamIdResponse =
      await http.post(getLivestreamIdUrl, headers: {
    "Authorization": _token,
  });
  if (livestreamIdResponse.statusCode != 200) {
    throw Exception(json.decode(livestreamIdResponse.body)["error"]);
  }
  var _livestreamID = json.decode(livestreamIdResponse.body)['roomId'];
  return _livestreamID;
}

Future<bool> validateLivestream(String token, String livestreamId) async {
  final Uri validateLivestreamUrl =
      Uri.parse('$_VIDEOSDK_API_ENDPOINT/rooms/validate/$livestreamId');
  final http.Response validateLivestreamResponse =
      await http.get(validateLivestreamUrl, headers: {
    "Authorization": token,
  });

  if (validateLivestreamResponse.statusCode != 200) {
    throw Exception(json.decode(validateLivestreamResponse.body)["error"]);
  }

  return validateLivestreamResponse.statusCode == 200;
}

Future<dynamic> fetchSession(String token, String livestreamId) async {
  final Uri getlivestreamIdUrl =
      Uri.parse('$_VIDEOSDK_API_ENDPOINT/sessions?roomId=$livestreamId');
  final http.Response livestreamIdResponse =
      await http.get(getlivestreamIdUrl, headers: {
    "Authorization": token,
  });
  List<dynamic> sessions = jsonDecode(livestreamIdResponse.body)['data'];
  return sessions.first;
}

Future<dynamic> fetchActiveHls(String token, String livestreamId) async {
  final Uri getActiveHlsUrl =
      Uri.parse('$_VIDEOSDK_API_ENDPOINT/hls/$livestreamId/active');
  final http.Response response = await http.get(getActiveHlsUrl, headers: {
    "Authorization": token,
  });
  Map<dynamic, dynamic> activeHls = jsonDecode(response.body)['data'];
  return activeHls;
}

Future<dynamic> fetchHls(String url) async {
  final http.Response response = await http.get(Uri.parse(url));
  log(response.body);
  return response.statusCode;
}
