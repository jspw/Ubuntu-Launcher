import 'Utility/libraries.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pink,
        accentColor: Colors.white
      ),
      title: "Ubuntu Launcher",
      initialRoute: Routes.initialScreen(),
      routes: Routes.routes(),
    );
  }
}
