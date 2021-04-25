import 'package:bloc/bloc.dart';
import 'package:device_apps/device_apps.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:launcher/src/constants/enums.dart';
import 'package:launcher/src/resources/apps_api_provider.dart';
import 'package:logger/logger.dart';

part 'apps_state.dart';

class AppsCubit extends Cubit<AppsState> {
  AppsCubit() : super(AppsInitiateState()) {
    getApps();
    // listenApps();
  }

  final appsApiProvider = AppsApiProvider();

  void getApps() async {
    emit(AppsLoading());
    try {
      List<Application> apps = await appsApiProvider.fetchAppList();
      apps.sort(
          (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
      emit(AppsLoaded(apps));
    } catch (errorMessage) {
      Logger().v(errorMessage);
      emit(AppsError(errorMessage));
    }
  }

  void listenApps() async {
    try {
      Stream<ApplicationEvent> apps = await DeviceApps.listenToAppsChanges();
      print(apps);
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
      print("Chaned $sortType");
      apps.sort(
          (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    } else if (sortType ==
        SortOptions.InstallationTime.toString().split('.').last) {
      apps.sort((b, a) => a.installTimeMillis.compareTo(b.installTimeMillis));
      print("Chaned $sortType");
    } else if (sortType == SortOptions.UpdateTime.toString().split('.').last) {
      apps.sort((b, a) => a.updateTimeMillis.compareTo(b.updateTimeMillis));
      print("Chaned $sortType");
    }

    print(apps);

    emit(AppsLoaded(apps));
  }
}
