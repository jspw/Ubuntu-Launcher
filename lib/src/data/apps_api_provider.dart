import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

class AppsApiProvider {
  Future<List<AppInfo>> fetchAppList() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: true,
    );

    return apps;
  }
}
