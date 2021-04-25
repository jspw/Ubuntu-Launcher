
import 'package:device_apps/device_apps.dart';

class AppsApiProvider {
  Future<List<Application>> fetchAppList() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: true,
        onlyAppsWithLaunchIntent: true);

    return apps;
  }
}
