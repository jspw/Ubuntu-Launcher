import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/src/blocs/apps_cubit.dart';
import 'package:launcher/src/config/routes/app_routes.dart';
import 'package:launcher/src/config/themes/cubit/opacity_cubit.dart';
import 'package:launcher/src/data/apps_api_provider.dart';

import './config/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AppsCubit(appsApiProvider: AppsApiProvider())..getApps(),
          ),
          BlocProvider<OpacityCubit>(create: (context) => OpacityCubit()),
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
