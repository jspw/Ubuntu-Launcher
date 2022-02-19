import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/src/blocs/apps_cubit.dart';

import 'package:launcher/src/config/themes/cubit/opacity_cubit.dart';
import 'package:launcher/src/core/modules/apps/views/app_drawer.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatelessWidget {
  static const route = '/';
  var scaffoldKey = GlobalKey<ScaffoldState>();

  double sidebarOpacity = 1;

  bool autoOpenDrawer;

  _launchCaller() async {
    const url = "tel:";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
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
            appsCubit.updateApps();
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
                                        Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                        ),
                                        () => _launchCaller(),
                                      ),
                                      shortcutAppsBuild(
                                        Icon(
                                          Icons.sms,
                                          color: Colors.white,
                                        ),
                                        () => DeviceApps.openApp(state
                                            .shortcutAppsModel
                                            .message
                                            .packageName),
                                      ),
                                      shortcutAppsBuild(
                                        Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                        ),
                                        () => DeviceApps.openApp(state
                                            .shortcutAppsModel
                                            .camera
                                            .packageName),
                                      ),
                                      shortcutAppsBuild(
                                        Icon(
                                          Icons.settings,
                                          color: Colors.white,
                                        ),
                                        () => DeviceApps.openApp(state
                                            .shortcutAppsModel
                                            .setting
                                            .packageName),
                                      )
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
            Logger().w(state);
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

Widget shortcutAppsBuild(Icon icon, Function fn) {
  return Padding(
    padding: const EdgeInsets.only(top: 15.0),
    child: IconButton(icon: icon, onPressed: fn),
  );
}
