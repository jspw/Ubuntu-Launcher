import 'package:launcher/src/config/constants/enums.dart';
import 'package:launcher/src/data/models/shortcut_app_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> setShortcutApps(ShortcutAppsModel shortcutApps) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(ShortcutAppTypes.CAMERA.name, shortcutApps.camera);
    prefs.setString(ShortcutAppTypes.PHONE.name, shortcutApps.phone);
    prefs.setString(ShortcutAppTypes.SETTINGS.name, shortcutApps.setting);
    prefs.setString(ShortcutAppTypes.MESSAGE.name, shortcutApps.message);
  }

  static Future<ShortcutAppsModel> getShortcutApps() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return ShortcutAppsModel(
        camera: prefs.getString(ShortcutAppTypes.CAMERA.name),
        phone: prefs.getString(ShortcutAppTypes.PHONE.name),
        setting: prefs.getString(ShortcutAppTypes.SETTINGS.name),
        message: prefs.getString(ShortcutAppTypes.MESSAGE.name));
  }

  static Future<void> setUserNew() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isNew", false);
  }

  static Future<bool> isUserNew() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isNew") ?? true;
  }

  static Future<void> setSortType(String sortType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sortType', sortType);
  }

  static Future<String> getSortType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sortType');
  }

  static Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
