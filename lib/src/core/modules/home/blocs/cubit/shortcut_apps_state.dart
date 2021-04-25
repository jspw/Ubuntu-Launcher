part of 'shortcut_apps_cubit.dart';

abstract class ShortcutAppsState extends Equatable {
  const ShortcutAppsState();

  @override
  List<Object> get props => [];
}

class ShortcutAppsInitial extends ShortcutAppsState {}

class ShortcutAppsLoaded extends ShortcutAppsState {
  final List<Application> shortcutApps;

  ShortcutAppsLoaded(this.shortcutApps);

    @override
  List<Object> get props => [shortcutApps];

}
