import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermessionHelper {
  Future<bool> checkPermission() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    bool permissionStatus;
    if (deviceInfo.version.sdkInt > 32) {
      permissionStatus = await Permission.photos.request().isGranted;
    } else {
      permissionStatus = await Permission.storage.request().isGranted;
    }

    if (permissionStatus) {
      log('Izin penyimpanan sudah diberikan.');
    } else {
      if (deviceInfo.version.sdkInt > 32) {
        log('deviceInfo.version.sdkInt > 32.');
        permissionStatus = await Permission.photos.request().isGranted;
      } else {
        permissionStatus = await Permission.storage.request().isGranted;
      }
      // } else {
      //   openAppSettings();
      // }
    }
    log('permissionStatus: $permissionStatus');
    return permissionStatus;
  }

  void permessionPrinter() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();

    log("statuses: $statuses");
  }
}
