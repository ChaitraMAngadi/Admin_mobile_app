import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceHeaders {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static Map<String, String>? _cachedHeaders;

  static Future<Map<String, String>>  getDeviceHeaders() async {
    if (_cachedHeaders != null) return _cachedHeaders!;

    try {
      final packageInfo = await PackageInfo.fromPlatform();

      if (Platform.isAndroid) {
        final android = await _deviceInfo.androidInfo;

        _cachedHeaders = {
          'X-Device-Type': 'mobile',
          'X-Device-OS': 'Android',
          'X-Device-OS-Version': android.version.release,
          'X-Device-OS-SDK': android.version.sdkInt.toString(),
          'X-Device-Model': android.model,
          'X-Device-Vendor': android.manufacturer,
          'X-Device-Brand': android.brand,
          'X-App-Version': packageInfo.version,
          'X-App-Build': packageInfo.buildNumber,
          'X-Device-ID': android.id,
          'X-Is-Physical-Device': android.isPhysicalDevice.toString(),
        };
      } else if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;

        _cachedHeaders = {
          'X-Device-Type': 'mobile',
          'X-Device-OS': 'iOS',
          'X-Device-OS-Version': ios.systemVersion,
          'X-Device-Model': ios.utsname.machine,
          'X-Device-Vendor': 'Apple',
          'X-App-Version': packageInfo.version,
          'X-App-Build': packageInfo.buildNumber,
          'X-Device-ID': ios.identifierForVendor ?? '',
          'X-Is-Physical-Device': ios.isPhysicalDevice.toString(),
        };
      } else {
        _cachedHeaders = {
          'X-Device-Type': 'unknown',
          'X-Device-OS': Platform.operatingSystem,
          'X-App-Version': packageInfo.version,
        };
      }
    } catch (e) {
      print('❌ Device header error: $e');

      _cachedHeaders = {
        'X-Device-Type': 'mobile',
        'X-Device-OS': Platform.operatingSystem,
      };
    }

    return _cachedHeaders!;
  }
}
