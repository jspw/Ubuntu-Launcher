import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/src/blocs/apps_cubit.dart';
import 'package:launcher/src/config/routes/app_routes.dart';
import 'package:launcher/src/config/themes/cubit/opacity_cubit.dart';

import 'package:launcher/src/blocs/shortcut_apps_cubit.dart';
import './config/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppsCubit appsCubit = new AppsCubit();
    return MultiBlocProvider(
        providers: [
          BlocProvider<AppsCubit>(create: (BuildContext context) => appsCubit),
          BlocProvider<OpacityCubit>(
              create: (BuildContext context) => OpacityCubit()),
          BlocProvider<ShortcutAppsCubit>(
              create: (BuildContext context) =>
                  ShortcutAppsCubit(appsCubit: appsCubit)),
        ],
        child: MaterialApp(
          showPerformanceOverlay: false,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primaryColor: Colors.pink,
              accentColor: Colors.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              canvasColor: Colors.transparent),
          darkTheme: ThemeData(
            // New
            brightness: Brightness.light, // New
          ),
          title: "Ubuntu Launcher",
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ));
  }
}
