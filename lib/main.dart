import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'constants/colors.dart';
import 'navigator_key.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Run Flutter App
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Material App
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VideoSDK Flutter Example',
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme().copyWith(
          color: primaryColor,
        ),
        primaryColor: primaryColor,
        scaffoldBackgroundColor: secondaryColor,
      ),
      home: const SplashScreen(),
      navigatorKey: navigatorKey,
    );
  }
}