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
  AppsCubit({@required this.appsApiProvider}) : super(AppsInitiateState()) {
    listenApps();
  }

  Future<void> loadApps() async {
    if (state is! AppsLoaded) emit(AppsLoading());

    try {
      List<Application> apps = await appsApiProvider.fetchAppList();
      Logger().w(apps.length);
      String sortType = await LocalStorage.getSortType() ??
          getCurrentPayloads(
              appsStatePayloadTypes: AppsStatePayloadTypes.SORT_TYPE) ??
          SortTypes.Alphabetically.name;

      apps = getAppsSorted(appsToSort: apps, sortType: sortType);

      final ShortcutAppsModel shortcutApps = getCurrentPayloads(
              appsStatePayloadTypes: AppsStatePayloadTypes.SHORTCUT_APPS) ??
          await getShortcutApps(apps);

      emit(AppsLoaded(
          shortcutAppsModel: shortcutApps,
          apps: apps,
          sortType: sortType ?? SortTypes.Alphabetically.name));
    } catch (error) {
      Logger().w(error);
      emit(AppsError(error.toString()));
    }
  }

  void updateApps(List<Application> apps) {
    final shortcutApps = getCurrentPayloads(
        appsStatePayloadTypes: AppsStatePayloadTypes.SHORTCUT_APPS);
    final sortType = getCurrentPayloads(
        appsStatePayloadTypes: AppsStatePayloadTypes.SORT_TYPE);
    emit(AppsLoading());
    emit(AppsLoaded(
        apps: apps, sortType: sortType, shortcutAppsModel: shortcutApps));
  }

  Future<void> updateSortType(String sortType) async {
    LocalStorage.setSortType(sortType);
    final apps = getAppsSorted(sortType: sortType);
    emit(AppsLoaded(
        apps: apps,
        sortType: sortType,
        shortcutAppsModel: getCurrentPayloads(
            appsStatePayloadTypes: AppsStatePayloadTypes.SHORTCUT_APPS)));
  }

  dynamic getCurrentPayloads({AppsStatePayloadTypes appsStatePayloadTypes}) {
    if (state is AppsLoaded) {
      final appState = state as AppsLoaded;
      return appsStatePayloadTypes == AppsStatePayloadTypes.APPS
          ? appState.apps
          : appsStatePayloadTypes == AppsStatePayloadTypes.SHORTCUT_APPS
              ? appState.shortcutAppsModel
              : appsStatePayloadTypes == AppsStatePayloadTypes.SORT_TYPE
                  ? appState.sortType
                  : {
                      appState.apps,
                      appState.shortcutAppsModel,
                      appState.sortType
                    };
    } else
      return null;
  }

  Future<ShortcutAppsModel> getShortcutApps(List<Application> apps) async {
    String settings, camera, sms, phone;

    try {
      final isNewUser = await LocalStorage.isUserNew();
      if (!isNewUser) {
        final shortcutApps = await LocalStorage.getShortcutApps();

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

  void updateShortcutApps(ShortcutAppsModel shortcutApps) {
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

    final apps =
        getCurrentPayloads(appsStatePayloadTypes: AppsStatePayloadTypes.APPS);

    final sortType = getCurrentPayloads(
        appsStatePayloadTypes: AppsStatePayloadTypes.SORT_TYPE);

    emit(AppsLoading());
    emit(AppsLoaded(
        apps: apps, sortType: sortType, shortcutAppsModel: shortcutApps));
  }

  Future<void> listenApps() async {
    try {
      Stream<ApplicationEvent> appsEvent = DeviceApps.listenToAppsChanges();

      appsEvent.listen((event) {
        if (state is AppsLoaded) {
          final appState = state as AppsLoaded;
          final apps = appState.apps;

          if (event.event == ApplicationEventType.disabled) {
            final applicationEventType = event as ApplicationEventDisabled;
            // TODO : may be there is a bug, adding is not visible in the app drawer!
            apps.add(applicationEventType.application);
            loadApps();
            Logger()
                .w("${applicationEventType.application.appName} is enabled");
          } else if (event.event == ApplicationEventType.enabled) {
            apps.removeWhere(
                (element) => element.packageName == event.packageName);
            Logger().w("${event.packageName} is disabled");
          } else if (event.event == ApplicationEventType.uninstalled) {
            final applicationEventType = event as ApplicationEventUninstalled;
            // TODO : Need to test this shit!
            apps.removeWhere((element) =>
                element.packageName == applicationEventType.packageName);
            Logger().w("${applicationEventType.packageName} is uninstalled");
          } else if (event.event == ApplicationEventType.installed) {
            final applicationEventType = event as ApplicationEventInstalled;
            // TODO : Need to test this shit!
            Application app = applicationEventType.application;
            apps.add(app);
            loadApps();

            Logger().w("${applicationEventType.application} is installed");
          }

          updateApps(apps);
        }
      });
    } catch (errorMessage) {
      Logger().w(errorMessage);
      emit(AppsError(errorMessage.toString()));
    }
  }

  List<Application> getAppsSorted(
      {List<Application> appsToSort, String sortType}) {
    List<Application> apps = appsToSort ??
        getCurrentPayloads(appsStatePayloadTypes: AppsStatePayloadTypes.APPS) ??
        [];

    if (sortType == null || sortType == SortTypes.Alphabetically.name) {
      apps.sort(
          (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    } else if (sortType == SortTypes.InstallationTime.name) {
      apps.sort((b, a) => a.installTimeMillis.compareTo(b.installTimeMillis));
    } else if (sortType == SortTypes.UpdateTime.name) {
      apps.sort((b, a) => a.updateTimeMillis.compareTo(b.updateTimeMillis));
    }

    return apps;
  }
}
