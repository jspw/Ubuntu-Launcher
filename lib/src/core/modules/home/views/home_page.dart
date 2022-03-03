import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/src/blocs/apps_cubit.dart';
import 'package:launcher/src/config/constants/colors.dart';
import 'package:launcher/src/config/constants/enums.dart';
import 'package:launcher/src/config/constants/size.dart';

import 'package:launcher/src/config/themes/cubit/opacity_cubit.dart';
import 'package:launcher/src/core/modules/apps/views/app_drawer.dart';
import 'package:launcher/src/data/models/shortcut_app_model.dart';
import 'package:launcher/src/helpers/widgets/error_message.dart';
import 'package:launcher/src/helpers/widgets/success_message.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatelessWidget {
  static const route = '/';
  var scaffoldKey = GlobalKey<ScaffoldState>();

  double sidebarOpacity = 1;

  bool autoOpenDrawer;

  // _launchCaller() async {
  //   const url = "tel:";
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final appsCubit = BlocProvider.of<AppsCubit>(context);

    final opacityCubit = BlocProvider.of<OpacityCubit>(context);

    Future<void> _showAppSelectDialog(ShortcutAppTypes appTypes) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!

        builder: (BuildContext context) {
          return AlertDialog(
            // scrollable: true,
            backgroundColor: Colors.transparent,
            title: Text(
              'Select ${appTypes.name} App',
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(fontSize: normalTextSize, color: Colors.pinkAccent),
            ),
            content: BlocBuilder<AppsCubit, AppsState>(
              builder: (context, state) {
                if (state is AppsLoaded)
                  return Card(
                    color: Colors.transparent,
                    child: Container(
                      height: deviceHeight / 2,
                      width: deviceWidth,
                      child: ListView(
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        children: <Widget>[
                          for (final app in state.apps)
                            GestureDetector(
                              onTap: () async {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                final ShortcutAppsModel shortcutApps =
                                    state.shortcutAppsModel;

                                switch (appTypes) {
                                  case ShortcutAppTypes.CAMERA:
                                    shortcutApps.camera = app.packageName;
                                    break;
                                  case ShortcutAppTypes.MESSAGE:
                                    shortcutApps.message = app.packageName;
                                    break;
                                  case ShortcutAppTypes.PHONE:
                                    shortcutApps.phone = app.packageName;
                                    break;
                                  case ShortcutAppTypes.SETTINGS:
                                    shortcutApps.setting = app.packageName;
                                    break;

                                  default:
                                    break;
                                }

                                BlocProvider.of<AppsCubit>(context)
                                    .updateShortcutApps(shortcutApps);

                                SuccessMessage(
                                  message:
                                      '${appTypes.name} application selected successfully.',
                                  context: context,
                                ).display();
                              },
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        app is ApplicationWithIcon
                                            ? CircleAvatar(
                                                backgroundImage: MemoryImage(
                                                  app.icon,
                                                ),
                                                backgroundColor: Colors.white,
                                              )
                                            : Icon(
                                                Icons.apps,
                                                size: iconSize,
                                              ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              app.appName,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: normalTextSize),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Divider()
                                  ],
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                else
                  return Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  );
              },
            ),
          );
        },
      );
    }

    Widget shortcutAppsBuild(
        IconData icon, String application, ShortcutAppTypes appType) {
      return GestureDetector(
        onTap: () async {
          if (application == null) {
            _showAppSelectDialog(appType);
          } else {
            try {
              bool isLaunchAble = await DeviceApps.openApp(application);
              Logger().w(isLaunchAble);
              if (!isLaunchAble) {
                // _showAppSelectDialog(appType);
                Navigator.pop(context);
                // DeviceApps.openAppSettings(application);
                ErrorMessage(
                        context: context,
                        fn: () => DeviceApps.openAppSettings(application),
                        seconds: 4,
                        error:
                            "Please tap here to enable the application first or long press on the app icon to change application.")
                    .display();
              }
            } catch (error) {
              Logger().w(error);
              ErrorMessage(
                      context: context,
                      error: "Something went wrong, Please try again.")
                  .display();
            }
          }
        },
        onLongPress: () => _showAppSelectDialog(appType),
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Icon(
            icon,
            size: iconSize,
            color: Colors.white,
          ),
        ),
      );
    }

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
            appsCubit.loadApps();
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
                        child: Column(
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
                              BlocBuilder<AppsCubit, AppsState>(
                                builder: (context, state) {
                                  if (state is AppsLoaded) {
                                    return Column(children: [
                                      shortcutAppsBuild(
                                          Icons.phone,
                                          state.shortcutAppsModel.phone,
                                          ShortcutAppTypes.PHONE),
                                      shortcutAppsBuild(
                                          Icons.sms,
                                          state.shortcutAppsModel.message,
                                          ShortcutAppTypes.MESSAGE),
                                      shortcutAppsBuild(
                                          Icons.camera,
                                          state.shortcutAppsModel.camera,
                                          ShortcutAppTypes.CAMERA),
                                      shortcutAppsBuild(
                                          Icons.settings,
                                          state.shortcutAppsModel.setting,
                                          ShortcutAppTypes.SETTINGS)
                                    ]);
                                  } else
                                    return Container();
                                },
                              ),
                              Opacity(
                                opacity: 0,
                                child: IconButton(
                                    onPressed: () {}, icon: Icon(Icons.menu)),
                              ),
                            ]))),
              );
            },
          ),
          body: BlocBuilder<AppsCubit, AppsState>(builder: (context, state) {
            if (state is AppsLoading)
              return SafeArea(
                child: Container(
                  key: scaffoldKey,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/boot2.gif"),
                    fit: BoxFit.fill,
                  )),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              );
            else if (state is AppsLoaded) {
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
          // drawerEnableOpenDragGesture:
          // (appsCubit.state is AppsLoaded) ? true : false,
        ),
      ),
    );
  }
}
