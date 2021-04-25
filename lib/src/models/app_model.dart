class AppModel  {
  String _appName;
  String _apkFilePath;
  String _packageName;
  String _versionName;
  int _versionCode;
  String _dataDir;
  bool _systemApp;
  int _installTimeMillis;
  int _updateTimeMillis;
  bool _enabled;

  AppModel(app) {
    _appName = app['appName'];

    _apkFilePath = app['apkFilePath'];
    _packageName = app['packageName'];
    _versionName = app['versionName'];
    _versionCode = app['versionCode'];
    _dataDir = app['dataDir'];
    _systemApp = app['systemApp'];
    _installTimeMillis = app['installTimeMillis'];
    _updateTimeMillis = app['updateTimeMillis'];
    _enabled = app['enabled'];
  }

  String get appName => _appName;
  String get apkFilePath => _apkFilePath;
  String get packageName => _packageName;
  String get versionName => _versionName;
  int get versionCode => _versionCode;
  String get dataDir => _dataDir;
  bool get systemApp => _systemApp;
  int get installTimeMillis => _installTimeMillis;
  int get updateTimeMillis => _updateTimeMillis;
  bool get enabled => _enabled;
}
