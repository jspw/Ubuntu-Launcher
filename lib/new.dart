
import 'package:flutter/material.dart';
import 'package:launcher/apps.dart';
import 'package:vector_math/vector_math.dart' as math;
import 'package:url_launcher/url_launcher.dart';

class New extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();

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
              onTap: () => Apps(context),
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
              () => print("Hello"),
              Icon(
                Icons.camera,
                color: Colors.white,
              ),
            ),
            buildIcons(
              () => print("Hello"),
              Icon(
                Icons.photo_album,
                color: Colors.white,
              ),
            ),
            buildIcons(
              () => print("object"),
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

void Apps(BuildContext context) {
  showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: MyApps(),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {});
}

void AppDetail(BuildContext context) {
  showGeneralDialog(
      context: context,
      pageBuilder: (context, anim1, anim2) {},
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      barrierLabel: '',
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.rotate(
          angle: math.radians(anim1.value * 360),
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
              title: Text('Hello!!'),
              content: Text('How are you?'),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 300));
}
