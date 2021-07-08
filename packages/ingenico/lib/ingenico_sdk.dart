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
      {required String clientSessionId,
      required String customerId,
      required String clientApiUrl,
      required String assetBaseUrl,
      required bool environmentIsProduction,
      required String applicationIdentifier}) async {
    final sessionRequest = SessionRequest();
    sessionRequest.clientSessionId = clientSessionId;
    sessionRequest.customerId = customerId;
    sessionRequest.clientApiUrl = clientApiUrl;
    sessionRequest.assetBaseUrl = assetBaseUrl;
    sessionRequest.environmentIsProduction = environmentIsProduction;
    sessionRequest.applicationIdentifier = applicationIdentifier;

    final session = await _api.initClientSession(sessionRequest);

    return Session(session.sessionId!);
  }
}

class BasicPaymentProduct {
  late String id;
  late String? paymentMethod;
  late String? paymentProductGroup;
  late double? minAmount;
  late double? maxAmount;
  late bool? allowsRecurring;
  late bool? allowsTokenization;
  late bool? usesRedirectionTo3rdParty;

  late DisplayHintsPaymentItem displayHints;
}

class DisplayHintsPaymentItem {
  late int displayOrder;
  late String label;
  late String logoUrl;
}

class Session {
  final String sessionId;
  static Api? _apiInstance;

  Session(this.sessionId);

  static Api get _api {
    if (_apiInstance == null) {
      _apiInstance = Api();
    }
    return _apiInstance!;
  }

  Future<List<BasicPaymentProduct>> getBasicPaymentProducts(
      {required double amountValue,
      required String currencyCode,
      required String countryCode,
      required bool isRecurring}) async {
    final paymentContextRequest = PaymentContextRequest();
    paymentContextRequest.amountValue = amountValue;
    paymentContextRequest.currencyCode = currencyCode;
    paymentContextRequest.countryCode = countryCode;
    paymentContextRequest.isRecurring = isRecurring;
    paymentContextRequest.sessionId = sessionId;

    final response = await _api.getBasicPaymentItems(paymentContextRequest);

    return response.basicPaymentProduct as List<BasicPaymentProduct>;
  }
}
