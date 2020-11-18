import 'libraries.dart';

class RouteAnimator {
  static Route createRoute(var apps, String sortType) {
    {
      return PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            Apps(apps, sortType),
        transitionsBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: widget,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 300),
        barrierDismissible: true,
        barrierLabel: '',
      );
    }
  }
}
