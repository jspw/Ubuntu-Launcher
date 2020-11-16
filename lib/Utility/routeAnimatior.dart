import 'libraries.dart';

class RouteAnimator {
  static Route createRoute(List<Application> apps) {
    {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Apps(apps),
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
