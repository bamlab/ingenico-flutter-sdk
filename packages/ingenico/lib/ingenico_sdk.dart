import 'dart:async';

import 'package:ingenico_platform_interface/main.dart' hide PaymentProduct;
import 'package:ingenico_sdk/pigeon.dart';

/// Class to interact with the Ingenico SDK
class IngenicoSdk implements IngenicoPlatform {
  static Api? _apiInstance;

  static Api get _api {
    if (_apiInstance == null) {
      _apiInstance = Api();
    }
    return _apiInstance!;
  }

  /// Convenience method for creating Session given the clientSessionId, customerId and region
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

/// Session contains all methods needed for making a payment
class Session {
  /// Id of the session
  final String sessionId;
  static Api? _apiInstance;

  /// Create an instance of [Session]
  Session(this.sessionId);

  static Api get _api {
    if (_apiInstance == null) {
      _apiInstance = Api();
    }
    return _apiInstance!;
  }

  /// Gets all basicPaymentItems for a given payment context
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

  /// Gets PaymentProduct with fields from the GC gateway
  Future<PaymentProduct> getPaymentProduct(
      {required String paymentProductId,
      required double amountValue,
      required String currencyCode,
      required String countryCode,
      required bool isRecurring}) async {
    final paymentProductRequest = GetPaymentProductRequest();
    paymentProductRequest.paymentProductId = paymentProductId;
    paymentProductRequest.amountValue = amountValue;
    paymentProductRequest.currencyCode = currencyCode;
    paymentProductRequest.countryCode = countryCode;
    paymentProductRequest.isRecurring = isRecurring;
    paymentProductRequest.sessionId = sessionId;

    final response = await _api.getPaymentProduct(paymentProductRequest);

    return response;
  }

  /// Get encrypted payment data
  Future<PreparedPaymentRequest> preparePaymentRequest(
      {required String paymentProductId,
      required Map<String, String> values,
      required String currencyCode,
      required bool tokenize,
      required String sessionId}) {
    final request = PaymentRequest();
    request.paymentProductId = paymentProductId;
    request.values = values;
    request.tokenize = tokenize;
    request.sessionId = sessionId;

    return _api.preparePaymentRequest(request);
  }
}
