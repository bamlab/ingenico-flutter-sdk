import 'package:pigeon/pigeon.dart';

class SessionRequest {
  late String clientSessionId;
  late String customerId;
  late String clientApiUrl;
  late String assetBaseUrl;
  late bool environmentIsProduction;
  late String applicationIdentifier;
}

class SessionResponse {
  late String sessionId;
}

class PaymentContextRequest {
  late String sessionId;
  late double amountValue;
  late String currencyCode;
  late String countryCode;
  late bool isRecurring;
}

class PaymentContextResponse {
  late List<BasicPaymentProduct> basicPaymentProduct;
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

@HostApi()
abstract class Api {
  SessionResponse initClientSession(SessionRequest request);

  @async
  PaymentContextResponse getBasicPaymentItems(PaymentContextRequest request);
}
