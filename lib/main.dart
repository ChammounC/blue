import 'dart:async';
import 'package:FlutterBluetooth/screens/starter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
      (value) => runApp(const MaterialApp(
          debugShowCheckedModeBanner: false, home: Starter())));
}
