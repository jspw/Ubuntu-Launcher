import 'package:flutter/material.dart';
import 'package:launcher/src/core/modules/404/views/404_page.dart';
import 'package:launcher/src/core/modules/apps/views/views.dart';
import 'package:launcher/src/core/modules/home/views/views.dart';
import 'package:launcher/src/helpers/utilities/routeAnimator.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Home.route:
        return MaterialPageRoute(builder: (_) => Home());

      case AppDrawer.route:
        return RouteAnimator.createRoute(AppDrawer());

      default:
        return MaterialPageRoute(
            builder: (_) =>
                Page404(errorMessage: "Could not find route ${settings.name}"));
    }
  }
}
