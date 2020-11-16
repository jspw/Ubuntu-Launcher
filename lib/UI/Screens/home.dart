

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

  _launchCaller() async {
    const url = "tel:";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchSms() async {
    const uri = 'sms:';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      const uri = 'sms:';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }

  void appInfo() async {
    var data = await AppInformations.appInfo();
    setState(() {
      apps = data;
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
              onTap: () {
                Navigator.of(context).push(RouteAnimator.createRoute(apps));
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
              () => _launchSms,
              Icon(
                Icons.message,
                color: Colors.white,
              ),
            ),
            buildIcons(
              () => AppSettings.openAppSettings(),
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
