import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:device_apps/device_apps.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:launcher/src/core/modules/apps/blocs/blocs.dart';
import 'package:launcher/src/resources/apps_api_provider.dart';

part 'shortcut_apps_state.dart';

class ShortcutAppsCubit extends Cubit<ShortcutAppsState> {
  // final AppsCubit appsCubit;
  final appsApiProvider = AppsApiProvider();

  // StreamSubscription appsStreamSubscription;

  ShortcutAppsCubit() : super(ShortcutAppsInitial()) {
    // appsStreamSubscription = appsCubit.stream.listen((appsState) {
    //   // print("inside cubit");
    //   // print(appsState);
    //   if (appsState is AppsLoaded) {
    //     getShortcutApps(appsState.apps);
    //   }
    // });
    getApps();
  }

  void getApps() async {
    List<Application> apps = await appsApiProvider.fetchAppList();
    apps.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    getShortcutApps(apps);
  }

  void getShortcutApps(apps) {
    Application settings, camera, sms, phone;

    for (int i = 0; i < apps.length; i++) {
      Application app = apps[i];
      if (app.appName == "Settings") {
        // settingsPackageNameDemo = app.packageName;
        settings = apps[i];
      } else if (app.appName == "Camera") {
        // cameraPackageNameDemo = app.packageName;
        camera = apps[i];
      } else if (app.appName == "Messages" || app.appName == "Messaging") {
        // messagesPackageNameDemo = app.packageName;
        sms = apps[i];
      } else if (app.appName == "Phone" || app.appName == "Call") {
        // messagesPackageNameDemo = app.packageName;
        phone = apps[i];
      }
    }

    List<Application> shortcutApps = [settings, camera, sms, phone];
    // print("Testing cubit");
    // print(shortcutApps);

    emit(ShortcutAppsLoaded(shortcutApps));

    //messaging apps packageNames in different android phones

//      "com.google.android.apps.messaging"
//      "com.jb.gosms"
//      "com.concentriclivers.mms.com.android.mms"
//      "fr.slvn.mms"
//      "com.android.mms"
//      "com.sonyericsson.conversations"

    //check message app installed or  not
    // if (await DeviceApps.isAppInstalled(messagesPackageNameDemo)) {
    //   messagesPackageNameDemo = messagesPackageNameDemo;
    // } else if (await DeviceApps.isAppInstalled(
    //     "com.google.android.apps.messaging")) {
    //   messagesPackageNameDemo = "com.google.android.apps.messaging";
    // } else if (await DeviceApps.isAppInstalled("com.jb.gosms")) {
    //   messagesPackageNameDemo = "com.jb.gosms";
    // } else if (await DeviceApps.isAppInstalled(
    //     "com.concentriclivers.mms.com.android.mms")) {
    //   messagesPackageNameDemo = "com.concentriclivers.mms.com.android.mms";
    // } else if (await DeviceApps.isAppInstalled("fr.slvn.mms")) {
    //   messagesPackageNameDemo = "fr.slvn.mms";
    // } else if (await DeviceApps.isAppInstalled("com.android.mms")) {
    //   messagesPackageNameDemo = "com.android.mms";
    // } else if (await DeviceApps.isAppInstalled(
    //     "com.sonyericsson.conversations")) {
    //   messagesPackageNameDemo = "com.sonyericsson.conversations";
    // }
  }

  void updateShortcutApp(shortcutApp) => {};

  @override
  Future<void> close() {
    // TODO: implement close
    // appsStreamSubscription.cancel();
    return super.close();
  }
}
