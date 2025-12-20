import 'package:bloc/bloc.dart';
import 'package:installed_apps/app_info.dart';
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
  AppsCubit({required this.appsApiProvider}) : super(AppsInitiateState());

  Future<void> loadApps() async {
    if (state is! AppsLoaded) emit(AppsLoading());

    try {
      List<AppInfo> apps = await appsApiProvider.fetchAppList();
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
          sortType: sortType));
    } catch (error) {
      Logger().w(error);
      emit(AppsError(error.toString()));
    }
  }

  void updateApps(List<AppInfo> apps) {
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

  dynamic getCurrentPayloads({AppsStatePayloadTypes? appsStatePayloadTypes}) {
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
    } else {
      return null;
    }
  }

  Future<ShortcutAppsModel> getShortcutApps(List<AppInfo> apps) async {
    String? settings, camera, sms, phone;

    try {
      final isNewUser = await LocalStorage.isUserNew();
      if (!isNewUser) {
        final shortcutApps = await LocalStorage.getShortcutApps();

        return shortcutApps;
      } else {
        for (int i = 0; i < apps.length; i++) {
          AppInfo app = apps[i];
          if (app.name == "Settings") {
            settings = apps[i].packageName;
          } else if (app.name.toLowerCase().contains("camera")) {
            camera = apps[i].packageName;
          } else if (app.name.toLowerCase().contains("message") ||
              app.name.toLowerCase().contains("messaging") ||
              app.name.toLowerCase().contains("sms") ||
              app.name.toLowerCase().contains("messenger")) {
            sms = apps[i].packageName;
          } else if (app.name.toLowerCase().contains("phone") ||
              app.name.toLowerCase().contains("call") ||
              app.name.toLowerCase().contains("dial")) {
            phone = apps[i].packageName;
          }
        }

        final shortcutApps = ShortcutAppsModel(
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
      return ShortcutAppsModel();
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

  List<AppInfo> getAppsSorted(
      {List<AppInfo>? appsToSort, String? sortType}) {
    List<AppInfo> apps = appsToSort ??
        getCurrentPayloads(appsStatePayloadTypes: AppsStatePayloadTypes.APPS) ??
        [];

    if (sortType == null || sortType == SortTypes.Alphabetically.name) {
      apps.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (sortType == SortTypes.InstallationTime.name) {
      apps.sort((b, a) => a.installedTimestamp.compareTo(b.installedTimestamp));
    } else if (sortType == SortTypes.UpdateTime.name) {
      // installed_apps doesn't have updateTime, use installedTimestamp as fallback
      apps.sort((b, a) => a.installedTimestamp.compareTo(b.installedTimestamp));
    }

    return apps;
  }
}
