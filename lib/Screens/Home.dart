import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:device_apps/device_apps.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  List<Application> apps;

  _launchCaller() async {
    const url = "tel:";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchSms() async {
    const url = "sms:";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void appInfo() async {
    apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );

    apps.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    print(apps);
  }

  void appsRef() {
    appInfo();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appInfo();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedErro
    return Scaffold(
      drawer: Container(
        color: Colors.pink.withOpacity(0.5),
        height: MediaQuery.of(context).size.height,
        width: 60.0,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            GestureDetector(
              onTap: () => showGeneralDialog(
                barrierColor: Colors.black.withOpacity(0.5),
                transitionBuilder: (context, a1, a2, widget) {
                  return Transform.scale(
                    scale: a1.value,
                    child: Opacity(
                      opacity: a1.value,
                      child: apps.length >= 1
                          ? Scaffold(
                              backgroundColor: Colors.transparent,
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                title: Text('Applications'),
                                titleSpacing: 2.0,
                                centerTitle: true,
                                leading: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    color: Colors.black,
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,
                                          size: 35.0,
                                        ),
                                        onPressed: null),
                                  ),
                                ),
                              ),
                              body: RefreshIndicator(
                                color: Colors.transparent,
                                onRefresh: () {
                                  setState(() {
                                    appInfo();
                                  });
                                },
                                child: GridView.count(
                                  physics: BouncingScrollPhysics(),
                                  crossAxisCount: 4,
                                  children: List.generate(apps.length, (int i) {
                                    Application app = apps[i];
                                    return GestureDetector(
                                        // onDoubleTap: () => showGeneralDialog(
                                        //       context: context,
                                        //       pageBuilder:
                                        //           (context, anim1, anim2) {},
                                        //       barrierDismissible: true,
                                        //       barrierColor:
                                        //           Colors.black.withOpacity(0.4),
                                        //       barrierLabel: '',
                                        //       transitionBuilder: (context,
                                        //           anim1, anim2, child) {
                                        //         return Transform.rotate(
                                        //           angle: math.radians(
                                        //               anim1.value * 360),
                                        //           child: Opacity(
                                        //             opacity: anim1.value,
                                        //             child: AlertDialog(
                                        //               shape: OutlineInputBorder(
                                        //                   borderRadius:
                                        //                       BorderRadius
                                        //                           .circular(
                                        //                               16.0)),
                                        //               title: Text(
                                        //                   "Application Detail"),
                                        //             ),
                                        //           ),
                                        //         );
                                        //       },
                                        //       transitionDuration:
                                        //           Duration(milliseconds: 300),
                                        //     ),
                                        onTap: () =>
                                            DeviceApps.openApp(app.packageName),
                                        child: GridTile(
                                          child: app is ApplicationWithIcon
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: <Widget>[
                                                      Container(
                                                        // height: 45,
                                                        // width: 45,
                                                        child: CircleAvatar(
                                                          backgroundImage:
                                                              MemoryImage(
                                                            app.icon,
                                                          ),
                                                          backgroundColor:
                                                              Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        app.appName,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : null,
                                        ));
                                  }),
                                ),
                              ),
                            )
                          : CircularProgressIndicator(),
                    ),
                  );
                },
                transitionDuration: Duration(milliseconds: 300),
                barrierDismissible: true,
                barrierLabel: '',
                context: context,
                pageBuilder: (context, animation1, animation2) {},
              ),
              child: Container(
                width: 35,
                child: Image.asset(
                  "assets/images/ic_launcher.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            buildIcons(
              _launchCaller,
              Icon(
                Icons.call,
                color: Colors.white,
              ),
            ),
            buildIcons(
              () => _launchSms,
              Icon(
                Icons.message,
                color: Colors.white,
              ),
            ),
            // buildIcons(
            //   () => print("Hello"),
            //   Icon(
            //     Icons.camera,
            //     color: Colors.white,
            //   ),
            // ),
            // buildIcons(
            //   () => print("Hello"),
            //   Icon(
            //     Icons.photo_album,
            //     color: Colors.white,
            //   ),
            // ),
            buildIcons(
              () =>AppSettings.openAppSettings(),
              Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        key: scaffoldKey,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/wallpaper.jpg"),
                fit: BoxFit.cover)),
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
      ),
    );
  }
}

Widget buildIcons(Function fn, Icon xicon) {
  return Padding(
    padding: const EdgeInsets.only(top: 15.0),
    child: IconButton(icon: xicon, onPressed: fn),
  );
}
