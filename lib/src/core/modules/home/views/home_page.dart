import 'dart:ffi';
import 'dart:typed_data';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/src/config/themes/cubit/opacity_cubit.dart';
import 'package:launcher/src/core/modules/apps/blocs/blocs.dart';
import 'package:launcher/src/core/modules/apps/views/app_drawer.dart';
import 'package:launcher/src/core/modules/home/blocs/cubit/shortcut_apps_cubit.dart';
import 'package:launcher/src/helpers/routeAnimatior.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatelessWidget {
  static const route = '/';
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Application> apps;
  String settingsPackageName;
  String cameraPackageName;
  String messagesPackageName;

  double sidebarOpacity = 1;

  bool autoOpenDrawer;

  // List<Application> shortcutApps = [];

  _launchCaller() async {
    const url = "tel:";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void drawerApps() async {}

  void getShortcutApps(apps) {
    Application settings, camera, sms, phone;

    for (int i = 0; i < apps.length; i++) {
      Application app = apps[i];
      if (app.appName == "Settings") {
        // settingsPackageNameDemo = app.packageName;
        settings = apps[i];
      } else if (app.appName == "Camera") {
        // cameraPackageNameDemo = app.packageName;
        camera = apps[i];
      } else if (app.appName == "Messages" || app.appName == "Messaging") {
        // messagesPackageNameDemo = app.packageName;
        sms = apps[i];
      } else if (app.appName == "Phone" || app.appName == "Call") {
        // messagesPackageNameDemo = app.packageName;
        phone = apps[i];
      }
    }

    List<Application> shortcutApps = [settings, camera, sms, phone];
    // print("Testing cubit");
    // print(shortcutApps);

    // emit(ShortcutAppsLoaded(shortcutApps));

    //messaging apps packageNames in different android phones

//      "com.google.android.apps.messaging"
//      "com.jb.gosms"
//      "com.concentriclivers.mms.com.android.mms"
//      "fr.slvn.mms"
//      "com.android.mms"
//      "com.sonyericsson.conversations"

    //check message app installed or  not
    // if (await DeviceApps.isAppInstalled(messagesPackageNameDemo)) {
    //   messagesPackageNameDemo = messagesPackageNameDemo;
    // } else if (await DeviceApps.isAppInstalled(
    //     "com.google.android.apps.messaging")) {
    //   messagesPackageNameDemo = "com.google.android.apps.messaging";
    // } else if (await DeviceApps.isAppInstalled("com.jb.gosms")) {
    //   messagesPackageNameDemo = "com.jb.gosms";
    // } else if (await DeviceApps.isAppInstalled(
    //     "com.concentriclivers.mms.com.android.mms")) {
    //   messagesPackageNameDemo = "com.concentriclivers.mms.com.android.mms";
    // } else if (await DeviceApps.isAppInstalled("fr.slvn.mms")) {
    //   messagesPackageNameDemo = "fr.slvn.mms";
    // } else if (await DeviceApps.isAppInstalled("com.android.mms")) {
    //   messagesPackageNameDemo = "com.android.mms";
    // } else if (await DeviceApps.isAppInstalled(
    //     "com.sonyericsson.conversations")) {
    //   messagesPackageNameDemo = "com.sonyericsson.conversations";
    // }
  }

  // void navigateScreen(widget) async {
  //   setState(() {
  //     sidebarOpacity = 0.30;
  //   });
  //   var app =
  //       await Navigator.of(context).push(RouteAnimator.createRoute(widget));
  //   setState(() {
  //     apps = app[0];

  //     sidebarOpacity = 1;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // print(apps);
    final appsCubit = BlocProvider.of<AppsCubit>(context);

    final opacityCubit = BlocProvider.of<OpacityCubit>(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Color.fromRGBO(39, 21, 40, 0.5),
        // systemNavigationBarColor: Color.fromRGBO(72, 33, 79, 1),
      ),
    );
    return WillPopScope(
      onWillPop: () async => false,
      child: Focus(
        onFocusChange: (isFocusChanged) {
          if (isFocusChanged) {
            opacityCubit.opacityReset();
            // appsCubit.getApps();
          }
        },
        child: Scaffold(
          drawer: BlocBuilder<OpacityCubit, OpacityState>(
            builder: (context, state) {
              return Opacity(
                opacity: state is OpacityInitial ? 1 : .30,
                child: SafeArea(
                    child: Container(
                  color: Color.fromRGBO(39, 21, 40, 0.5),
                  // Colors.pink.withOpacity(0.5),
                  height: MediaQuery.of(context).size.height,
                  width: 60.0,
                  child: BlocBuilder<ShortcutAppsCubit, ShortcutAppsState>(
                      builder: (context, state) {
                    if (state is ShortcutAppsLoaded) {
                      List<Application> shortcutApps = state.shortcutApps;

                      print(shortcutApps.length);

                      // List x =;

                      return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    opacityCubit.setOpacitySemi();

                                    Navigator.pushNamed(
                                        context, AppDrawer.route);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    // width: 35,
                                    child: ClipRRect(
                                      child: Hero(
                                        tag: 'drawer',
                                        child: Image.asset(
                                          "assets/images/drawer.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: List.generate(
                                shortcutApps.length,
                                (index) {
                                  Application shortcutApp = shortcutApps[index];
                                  print("shortcutApp");
                                  print(shortcutApp);
                                  return shortcutApp is ApplicationWithIcon
                                      ? shortcutAppsBuild(
                                          shortcutApp.icon,
                                          () => DeviceApps.openApp(
                                              shortcutApp.packageName))
                                      : null;
                                },
                              ),
                            ),
                            Opacity(
                              opacity: 0,
                              child: IconButton(
                                  onPressed: () {}, icon: Icon(Icons.menu)),
                            ),
                          ]);
                    } else
                      return Container();
                  }),
                )),
              );
            },
          ),
          body: BlocBuilder<AppsCubit, AppsState>(builder: (context, state) {
            if (state is AppsLoading)
              return Container(
                key: scaffoldKey,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("assets/images/ubuntu-splash-screen.gif"),
                  fit: BoxFit.cover,
                )),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              );
            else if (state is AppsLoaded) {
              apps = state.apps;
              return Container(
                key: scaffoldKey,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("assets/images/wallpaper.jpg"),
                  fit: BoxFit.cover,
                )),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        scaffoldKey.currentState.openDrawer();
                      },
                      child: Container(
                          color: Colors.transparent,
                          height: MediaQuery.of(context).size.height,
                          child: SizedBox(
                            width: 70,
                          )),
                    ),
                  ],
                ),
              );
            } else {
              return Stack(
                children: [
                  Container(
                    key: scaffoldKey,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image:
                          AssetImage("assets/images/ubuntu-splash-screen.gif"),
                      fit: BoxFit.cover,
                    )),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text("Something went wrong!"),
                  )
                ],
              );
            }
          }),
          // drawerEnableOpenDragGesture: (apps == null) ? false : true,
        ),
      ),
    );
  }
}

Widget shortcutAppsBuild(Uint8List icon, Function fn) {
  return GestureDetector(
    onTap: fn,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Image.memory(
        icon,
        // color: Colors.transparent,
      ),
    ),
  );
}
