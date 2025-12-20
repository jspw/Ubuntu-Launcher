class ShortcutAppsModel {
  String? phone;
  String? message;
  String? camera;
  String? setting;

  ShortcutAppsModel({this.phone, this.camera, this.message, this.setting});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phone'] = phone;
    data['message'] = message;
    data['camera'] = camera;
    data['setting'] = setting;
    return data;
  }
}
