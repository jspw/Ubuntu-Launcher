import 'libraries.dart';

class Routes {
  static routes() {
    return {
      Home.route: (context) => Home(),
    };
  }

  static initialScreen() {
    return Home.route;
  }
}
