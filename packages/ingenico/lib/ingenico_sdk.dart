import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ingenico_platform_interface/main.dart';

class IngenicoSdk implements IngenicoPlatform {
  static const MethodChannel _channel = const MethodChannel('ingenico_sdk');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
