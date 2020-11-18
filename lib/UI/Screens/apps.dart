import '../../Utility/libraries.dart';

class Apps extends StatefulWidget {
  List<Application> apps;
  String sortType;

  Apps(this.apps, this.sortType);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // throw UnimplementedError();
    return AppsState(apps, sortType);
  }
}

class AppsState extends State {
  List<Application> apps;

  bool isSort = true;

  List<String> sortTypes = [
    'Alphabetically',
    'Installation Time',
    'UpdateTime',
  ];

  String sortType;

  AppsState(this.apps, this.sortType);

  Future<void> appInfo() async {
    var data = await AppInformations.appInfo(sortType);
    setState(() {
      apps = data;
    });
  }

  void sortApps(String isSort) {
    setState(() {
      if (sortType == "Alphabetically")
        apps.sort((a, b) =>
            a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
      else if (sortType == "Installation Time")
        apps.sort((b, a) => a.installTimeMillis.compareTo(b.installTimeMillis));
      else if (sortType == "UpdateTime")
        apps.sort((b, a) => a.updateTimeMillis.compareTo(b.updateTimeMillis));
    });
  }

  Widget sortTypeList() {
    return DropdownButton<String>(
      // value: sortType,
      icon: Icon(
        Icons.sort,
        color: Colors.white,
      ),
      iconSize: 35,
      elevation: 16,

      style: TextStyle(color: Colors.black),
      underline: Container(
        // color: Colors.pink[900],
        child: Text(""),
      ),
      onChanged: (String newValue) {
        setState(() {
          sortType = newValue;
        });

        sortApps(sortType);
      },
      items: sortTypes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  @override
  void initState() {
    appInfo();
    super.initState();
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
        backgroundColor: Colors.transparent,
        title: Text(
          'Applications',
          style: TextStyle(fontSize: 25),
        ),
        titleSpacing: 1.2,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context, [apps, sortType]),
          child: Container(
            child: Image.asset(
              "assets/images/ic_launcher.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: <Widget>[
          sortTypeList(),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.transparent,
        onRefresh: () => appInfo(),
        child: apps == null
            ? Center(
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.transparent,
                  child: Image.asset(
                    "assets/images/loader2.gif",
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : GridView.count(
                padding: const EdgeInsets.only(left: 50),
                physics: BouncingScrollPhysics(),
                crossAxisCount: 4,
                children: List.generate(apps.length, (int i) {
                  Application app = apps[i];
                  return GestureDetector(
                      onTap: () {
                        DeviceApps.openApp(app.packageName);
                        Navigator.pop(context, [apps, sortType]);
                      },
                      child: app is ApplicationWithIcon
                          ? GridTile(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
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
