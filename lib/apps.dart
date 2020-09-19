import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class MyApps extends StatefulWidget {
  static const route = '/apps';
  @override
  _MyAppsState createState() => _MyAppsState();
}

class _MyAppsState extends State<MyApps> {
  bool _showSystemApps = false;
  bool _onlyLaunchableApps = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Installed Applications'),
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
          )
          // actions: <Widget>[
          //   PopupMenuButton<String>(
          //     itemBuilder: (BuildContext context) {
          //       return <PopupMenuItem<String>>[
          //         PopupMenuItem<String>(
          //             value: 'system_apps', child: Text('Toggle system apps')),
          //         PopupMenuItem<String>(
          //           value: 'launchable_apps',
          //           child: Text('Toggle launchable apps only'),
          //         )
          //       ];
          //     },
          //     onSelected: (String key) {
          //       if (key == 'system_apps') {
          //         setState(() {
          //           _showSystemApps = !_showSystemApps;
          //         });
          //       }
          //       if (key == 'launchable_apps') {
          //         setState(() {
          //           _onlyLaunchableApps = !_onlyLaunchableApps;
          //         });
          //       }
          //     },
          //   )
          // ],
          ),
      body: _ListAppsPagesContent(
          includeSystemApps: _showSystemApps,
          onlyAppsWithLaunchIntent: _onlyLaunchableApps,
          key: GlobalKey()),
    );
  }
}

class _ListAppsPagesContent extends StatelessWidget {
  final bool includeSystemApps;
  final bool onlyAppsWithLaunchIntent;

  const _ListAppsPagesContent({
    Key key,
    this.includeSystemApps: false,
    this.onlyAppsWithLaunchIntent: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Application>>(
      future: DeviceApps.getInstalledApplications(
          includeAppIcons: true,
          includeSystemApps: includeSystemApps,
          onlyAppsWithLaunchIntent: onlyAppsWithLaunchIntent),
      builder: (BuildContext context, AsyncSnapshot<List<Application>> data) {
        if (data.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          List<Application> apps = data.data;
          print(apps);
          return Scrollbar(
            child: GridView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int position) {
                  Application app = apps[position];
                  return GestureDetector(
                    onTap: () => DeviceApps.openApp(app.packageName),
                    child: GridTile(
                      child: app is ApplicationWithIcon
                          ? Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    height: 50,
                                    width: 50,
                                    child: CircleAvatar(
                                      backgroundImage: MemoryImage(app.icon),
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    app.appName,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                  );
                },
                itemCount: apps.length),
          );
        }
      },
    );
  }
}
