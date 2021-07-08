import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ingenico_platform_interface/main.dart';
import 'package:ingenico_sdk/pigeon.dart';

class IngenicoSdk implements IngenicoPlatform {
  static Api? _apiInstance;

  static Api get _api {
    if (_apiInstance == null) {
      _apiInstance = Api();
    }
    return _apiInstance!;
  }

  static Future<Session> initClientSession(
      SessionRequest sessionRequest) async {
    final Session session = await _api.initClientSession(sessionRequest);
    return session;
  }
}
