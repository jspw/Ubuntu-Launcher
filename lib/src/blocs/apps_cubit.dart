import 'package:bloc/bloc.dart';
import 'package:device_apps/device_apps.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:launcher/src/config/constants/enums.dart';
import 'package:launcher/src/data/apps_api_provider.dart';
import 'package:launcher/src/data/models/shortcut_app_model.dart';
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

      final ShortcutAppsModel shortcutApps = getShortcutApps(apps);

      emit(AppsLoaded(
          shortcutAppsModel: shortcutApps,
          apps: apps,
          sortType: SortOptions.Alphabetically.toString().split('.').last));
    } catch (errorMessage) {
      Logger().v(errorMessage);
      emit(AppsError(errorMessage));
    }
  }

  ShortcutAppsModel getShortcutApps(apps) {
    Application settings, camera, sms, phone;

    for (int i = 0; i < apps.length; i++) {
      Application app = apps[i];
      if (app.appName == "Settings") {
        settings = apps[i];
      } else if (app.appName == "Camera") {
        camera = apps[i];
      } else if (app.appName == "Messages" || app.appName == "Messaging") {
        sms = apps[i];
      } else if (app.appName == "Phone" || app.appName == "Call") {
        phone = apps[i];
      }
    }

    return new ShortcutAppsModel(
        phone: phone, camera: camera, setting: settings, message: sms);
  }

  void updateApps() async {
    if (state is AppsLoaded) {
      String sortType = state.props[1];
      List<Application> apps = await appsApiProvider.fetchAppList();
      final ShortcutAppsModel shortcutApps = getShortcutApps(apps);
      emit(AppsLoaded(
          shortcutAppsModel: shortcutApps, apps: apps, sortType: sortType));
      sortApps(sortType);
    }
  }

  void listenApps() async {
    try {
      Stream<ApplicationEvent> apps = await DeviceApps.listenToAppsChanges();
      // print(apps);
      getApps();
    } catch (errorMessage) {
      emit(AppsError(errorMessage));
    }
  }

  void sortApps(String sortType) {
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

    final ShortcutAppsModel shortcutApps = getShortcutApps(apps);

    emit(AppsLoaded(
        apps: apps, sortType: sortType, shortcutAppsModel: shortcutApps));
  }
}
