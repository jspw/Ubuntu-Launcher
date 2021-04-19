import 'src/helpers/libraries.dart';

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
        accentColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        // New
        brightness: Brightness.light, // New
      ),
      title: "Ubuntu Launcher",
      initialRoute: Routes.initialScreen(),
      routes: Routes.routes(),
    );
  }
}
