import 'package:bloc/bloc.dart';
import 'package:device_apps/device_apps.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:launcher/src/config/constants/enums.dart';
import 'package:launcher/src/data/apps_api_provider.dart';
import 'package:launcher/src/data/models/shortcut_app_model.dart';
import 'package:launcher/src/helpers/utilities/local_storage.dart';
import 'package:logger/logger.dart';

part 'apps_state.dart';

class AppsCubit extends Cubit<AppsState> {
  final AppsApiProvider appsApiProvider;
  AppsCubit({@required this.appsApiProvider}) : super(AppsInitiateState());

  void getApps() async {
    emit(AppsLoading());
    try {
      List<Application> apps = await appsApiProvider.fetchAppList();
      apps.sort(
          (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

      final ShortcutAppsModel shortcutApps = await getShortcutApps(apps);

      emit(AppsLoaded(
          shortcutAppsModel: shortcutApps,
          apps: apps,
          sortType: SortOptions.Alphabetically.toString().split('.').last));
    } catch (errorMessage) {
      Logger().v(errorMessage);
      emit(AppsError(errorMessage));
    }
  }

  Future<ShortcutAppsModel> getShortcutApps(List<Application> apps) async {
    String settings, camera, sms, phone;

    try {
      final isNewUser = await LocalStorage.isUserNew();
      if (!isNewUser) {
        final shortcutApps = await LocalStorage.getShortcutApps();
        Logger().w(shortcutApps.toJson());

        return shortcutApps;
      } else {
        for (int i = 0; i < apps.length; i++) {
          Application app = apps[i];
          if (app.appName == "Settings") {
            settings = apps[i].packageName;
          } else if (app.appName.toLowerCase().contains("camera")) {
            camera = apps[i].packageName;
          } else if (app.appName.toLowerCase().contains("message") ||
              app.appName.toLowerCase().contains("messaging") ||
              app.appName.toLowerCase().contains("sms") ||
              app.appName.toLowerCase().contains("messenger")) {
            sms = apps[i].packageName;
          } else if (app.appName.toLowerCase().contains("phone") ||
              app.appName.toLowerCase().contains("call")) {
            phone = apps[i].packageName;
          }
        }

        final shortcutApps = new ShortcutAppsModel(
            phone: phone, camera: camera, setting: settings, message: sms);

        if (shortcutApps.phone != null &&
            shortcutApps.camera != null &&
            shortcutApps.setting != null &&
            shortcutApps.message != null) {
          LocalStorage.setShortcutApps(shortcutApps);

          LocalStorage.setUserNew();
        }

        return shortcutApps;
      }
    } catch (error) {
      Logger().w(error);
    }
  }

  void changeShortcutApps(ShortcutAppsModel shortcutApps) {
    final appsState = state as AppsLoaded;
    try {
      if (shortcutApps.phone != null &&
          shortcutApps.camera != null &&
          shortcutApps.setting != null &&
          shortcutApps.message != null) {
        LocalStorage.setShortcutApps(shortcutApps);

        LocalStorage.setUserNew();
      }
    } catch (error) {
      Logger().w(error);
    }
    emit(AppsLoading());
    emit(AppsLoaded(
        apps: appsState.apps,
        sortType: appsState.sortType,
        shortcutAppsModel: shortcutApps));
  }

  // void updateApps() async {
  //   if (state is AppsLoaded) {
  //     String sortType = state.props[1];
  //     List<Application> apps = await appsApiProvider.fetchAppList();
  //     final ShortcutAppsModel shortcutApps = getShortcutApps(apps);
  //     emit(AppsLoaded(
  //         shortcutAppsModel: shortcutApps, apps: apps, sortType: sortType));
  //     sortApps(sortType);
  //   }
  // }

  void listenApps() async {
    try {
      Stream<ApplicationEvent> apps = await DeviceApps.listenToAppsChanges();
      // print(apps);
      getApps();
    } catch (errorMessage) {
      emit(AppsError(errorMessage));
    }
  }

  void sortApps(String sortType) async {
    List<Application> apps = [];

    if (state is AppsLoaded) {
      apps = state.props[0];
    }

    emit(AppsLoading());

    if (sortType == SortOptions.Alphabetically.toString().split('.').last) {
      apps.sort(
          (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    } else if (sortType ==
        SortOptions.InstallationTime.toString().split('.').last) {
      apps.sort((b, a) => a.installTimeMillis.compareTo(b.installTimeMillis));
    } else if (sortType == SortOptions.UpdateTime.toString().split('.').last) {
      apps.sort((b, a) => a.updateTimeMillis.compareTo(b.updateTimeMillis));
    }

    final ShortcutAppsModel shortcutApps = await getShortcutApps(apps);

    emit(AppsLoaded(
        apps: apps, sortType: sortType, shortcutAppsModel: shortcutApps));
  }
}
