import '../../Utility/libraries.dart';

class Home extends StatefulWidget {
  static const route = '/home';

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  List<Application> apps;

  String sortType = "Alphabetically";

  String settingsPackageName;
  String cameraPackageName;
  String messagesPackageName;

  double sidebarOpacity = 1;

  _launchCaller() async {
    const url = "tel:911";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void drawerApps() async {}

  void appInfo() async {
    var data = await AppInformations.appInfo(sortType);
    setState(() {
      apps = data;
    });

    print(apps);

    for (int i = 0; i < apps.length; i++) {
      print(apps[i].appName);
    }

    String settingsPackageNameDemo;
    String cameraPackageNameDemo;
    String messagesPackageNameDemo;

    for (int i = 0; i < apps.length; i++) {
      Application app = apps[i];
      if (app.appName == "Settings") {
        settingsPackageNameDemo = app.packageName;
      }
      if (app.appName == "Camera") {
        cameraPackageNameDemo = app.packageName;
      }
      if (app.appName == "Messages") {
        messagesPackageNameDemo = app.packageName;
      }
    }

    setState(() {
      settingsPackageName = settingsPackageNameDemo;
      cameraPackageName = cameraPackageNameDemo;
      messagesPackageName = messagesPackageNameDemo;
    });
  }

  void navigateScreen() async {
    setState(() {
      sidebarOpacity = 0.30;
    });
    var app = await Navigator.of(context)
        .push(RouteAnimator.createRoute(apps, sortType));
    setState(() {
      apps = app[0];
      sortType = app[1];
      sidebarOpacity = 1;
    });
  }

  @override
  void initState() {
    appInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedErro
    return Scaffold(
      drawer: Opacity(
        opacity: sidebarOpacity,
        child: Container(
          color: Colors.pink.withOpacity(0.5),
          height: MediaQuery.of(context).size.height,
          width: 60.0,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              GestureDetector(
                onTap: () {
                  navigateScreen();
                },
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
                () => DeviceApps.openApp(messagesPackageName),
                Icon(
                  Icons.message,
                  color: Colors.white,
                ),
              ),
              buildIcons(
                () => DeviceApps.openApp(cameraPackageName),
                Icon(
                  Icons.camera,
                  color: Colors.white,
                ),
              ),
              buildIcons(
                () => DeviceApps.openApp(settingsPackageName),
                Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        key: scaffoldKey,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage((apps == null)
              ? "assets/images/ubuntu-splash-screen.gif"
              : "assets/images/wallpaper.jpg"),
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
