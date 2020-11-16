import '../../Utility/libraries.dart';

class Apps extends StatefulWidget {
  List<Application> apps;

  Apps(this.apps);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // throw UnimplementedError();
    return AppsState(apps);
  }
}

class AppsState extends State {
  List<Application> apps;
  AppsState(this.apps);

  Future<void> appInfo() async {
    apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );

    apps.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

    setState(() {
      apps = apps;
    });
    print(apps);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // arguments = ModalRoute.of(context).settings.arguments;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedError();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.pink.withOpacity(0.5),
        title: Text(
          'Applications',
          style: TextStyle(fontSize: 25),
        ),
        titleSpacing: 1.2,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            // color: Colors.black,
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
        onRefresh: () => appInfo(),
        child: apps == null
            ? Center(child: Image.asset("assets/images/loader.gif"))
            : GridView.count(
                physics: BouncingScrollPhysics(),
                crossAxisCount: 4,
                children: List.generate(apps.length, (int i) {
                  Application app = apps[i];
                  return GestureDetector(
                      onTap: () => DeviceApps.openApp(app.packageName),
                      child: app is ApplicationWithIcon
                          ? Card(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      child: CircleAvatar(
                                        backgroundImage: MemoryImage(
                                          app.icon,
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      app.appName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : null);
                }),
              ),
      ),
    );
  }
}
