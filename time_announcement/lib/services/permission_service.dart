import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> notificationStatus() =>
      Permission.notification.status;

  Future<PermissionStatus> exactAlarmStatus() =>
      Permission.scheduleExactAlarm.status;

  Future<void> requestAllPermissions() async {
    await [Permission.notification, Permission.scheduleExactAlarm].request();
  }

  // Opens the device's app settings page, for when a permission is denied
  Future<bool> openSettings() => openAppSettings();
}
