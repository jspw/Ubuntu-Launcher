import 'package:flutter/material.dart';
import 'Screens/apps.dart';
import 'Screens/Home.dart';

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
        '/': (context) => Home(),
        MyApps.route: (context) => MyApps(),
      },
    );
  }
}
