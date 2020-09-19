import 'package:flutter/material.dart';
import 'package:launcher/apps.dart';
import 'package:launcher/new.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedError();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pink,
      ),
      title: "Ubuntu Launcher",
      initialRoute: "/",
      routes: {
        '/': (context) => New(),
        MyApps.route: (context) => MyApps(),
      },
    );
  }
}
