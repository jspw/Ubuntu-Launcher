import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/src/blocs/apps_cubit.dart';
import 'package:launcher/src/config/routes/app_routes.dart';
import 'package:launcher/src/config/themes/cubit/opacity_cubit.dart';
import 'package:launcher/src/data/apps_api_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AppsCubit(appsApiProvider: AppsApiProvider())..loadApps(),
          ),
          BlocProvider<OpacityCubit>(create: (context) => OpacityCubit()),
        ],
        child: MaterialApp(
          showPerformanceOverlay: false,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primaryColor: Colors.pink,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.pink,
                secondary: Colors.white,
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              canvasColor: Colors.transparent),
          darkTheme: ThemeData(
            brightness: Brightness.light,
          ),
          title: "Ubuntu Launcher",
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ));
  }
}
