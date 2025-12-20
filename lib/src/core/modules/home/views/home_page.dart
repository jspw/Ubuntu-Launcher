import 'dart:io';

import 'package:installed_apps/installed_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/src/blocs/apps_cubit.dart';
import 'package:launcher/src/config/constants/enums.dart';
import 'package:launcher/src/config/constants/size.dart';

import 'package:launcher/src/config/themes/cubit/opacity_cubit.dart';
import 'package:launcher/src/core/modules/apps/views/app_drawer.dart';
import 'package:launcher/src/data/models/shortcut_app_model.dart';
import 'package:launcher/src/helpers/utilities/image_picker.dart';
import 'package:launcher/src/helpers/utilities/local_storage.dart';
import 'package:launcher/src/helpers/widgets/custom_snackbar.dart';
import 'package:launcher/src/helpers/widgets/error_message.dart';
import 'package:launcher/src/helpers/widgets/success_message.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  static const route = '/';

  const Home({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  double sidebarOpacity = 1;

  String defaultWallpaper = "assets/images/wallpaper.jpg";

  String starterIcon = "assets/images/drawer.png";

  bool? autoOpenDrawer;

  String? currentWallpaper;

  Future<void> loadWallpaper() async {
    currentWallpaper = await LocalStorage.getWallpaper();
    setState(() {});
  }

  @override
  void initState() {
    loadWallpaper();
    super.initState();
  }

  _launchCaller() async {
    final Uri url = Uri.parse("tel:");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appsCubit = BlocProvider.of<AppsCubit>(context);

    final opacityCubit = BlocProvider.of<OpacityCubit>(context);

    Future<void> showAppSelectDialog(ShortcutAppTypes appTypes) async {
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
                if (state is AppsLoaded) {
                  return Card(
                    color: Colors.transparent,
                    child: SizedBox(
                      height: deviceHeight / 2,
                      width: deviceWidth,
                      child: ListView(
                        physics: const ScrollPhysics(),
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
                                        app.icon != null
                                            ? CircleAvatar(
                                                backgroundImage: MemoryImage(
                                                  app.icon!,
                                                ),
                                                backgroundColor: Colors.white,
                                              )
                                            : Icon(
                                                Icons.apps,
                                                size: iconSize,
                                              ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              app.name,
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
                } else {
                  return Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }
              },
            ),
          );
        },
      );
    }

    Widget shortcutAppsBuild(
        IconData icon, String? application, ShortcutAppTypes appType) {
      return GestureDetector(
        onTap: () async {
          if (application == null) {
            showAppSelectDialog(appType);
          } else {
            try {
              // Todo : Need to fix this.
              // there is bug where system dial app is not working for some phone or dial app is not visible in device apps

              if (appType == ShortcutAppTypes.PHONE) {
                _launchCaller();
              } else {
                await InstalledApps.startApp(application);
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
        onLongPress: () => showAppSelectDialog(appType),
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
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Color.fromRGBO(39, 21, 40, 0.5),
        // systemNavigationBarColor: Color.fromRGBO(72, 33, 79, 1),
      ),
    );

    return PopScope(
      canPop: false,
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
                        color: const Color.fromRGBO(39, 21, 40, 0.5),
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
                                            starterIcon,
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
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                              Opacity(
                                opacity: 0,
                                child: IconButton(
                                    onPressed: () {}, icon: const Icon(Icons.menu)),
                              ),
                            ]))),
              );
            },
          ),
          body: BlocBuilder<AppsCubit, AppsState>(builder: (context, state) {
            if (state is AppsLoading) {
              return SafeArea(
                child: Container(
                  key: scaffoldKey,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/boot2.gif"),
                    fit: BoxFit.fill,
                  )),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              );
            } else if (state is AppsLoaded) {
              return GestureDetector(
                onLongPress: () async {
                  pickImageFile(context, (image) async {
                    if (image == null) {
                      CustomSnackBar(
                              context: context,
                              message: "No image is selected",
                              color: Colors.yellow)
                          .display();
                    } else {
                      setState(() {
                        currentWallpaper = image.path;
                        LocalStorage.setWallpaper(image.path);
                      });
                      SuccessMessage(
                              context: context,
                              message: "Wallpaper changed successfully")
                          .display();
                    }
                  });
                },
                child: Container(
                  key: scaffoldKey,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: currentWallpaper != null
                        ? FileImage(File(currentWallpaper!)) as ImageProvider
                        : AssetImage(defaultWallpaper) as ImageProvider,
                    fit: BoxFit.cover,
                  )),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                            color: Colors.transparent,
                            height: MediaQuery.of(context).size.height,
                            child: const SizedBox(
                              width: 70,
                            )),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Stack(
                children: [
                  Container(
                    key: scaffoldKey,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image:
                          AssetImage("assets/images/ubuntu-splash-screen.gif"),
                      fit: BoxFit.cover,
                    )),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                  const Align(
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
