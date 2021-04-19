import 'libraries.dart';

class AppInformations {
  static Future<List<Application>> appInfo(String sortType) async {
    var apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    if (sortType == "Alphabetically")
      apps.sort(
          (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    else if (sortType == "Installation Time")
      apps.sort((b, a) => a.installTimeMillis.compareTo(b.installTimeMillis));
    else if (sortType == "UpdateTime")
      apps.sort((b, a) => a.updateTimeMillis.compareTo(b.updateTimeMillis));
    return apps;
  }
}
