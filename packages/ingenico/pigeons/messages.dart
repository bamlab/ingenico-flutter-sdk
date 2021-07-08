import 'package:pigeon/pigeon.dart';

class SessionRequest {
  late String clientSessionId;
  late String customerId;
  late String clientApiUrl;
  late String assetBaseUrl;
  late bool environmentIsProduction;
  late String applicationIdentifier;
}

class Session {
  late String sessionId;
}

class PaymentContextRequest {
  late double amountValue;
  late String currencyCode;
  late String countryCode;
  late bool isRecurring;
}

class BasicPaymentItem {
  late String id;
  late DisplayHintsPaymentItem displayHints;
}

class DisplayHintsPaymentItem {
  late int displayOrder;
  late String label;
  late String logoUrl;
}

@HostApi()
abstract class Api {
  Session initClientSession(SessionRequest request);

  List<BasicPaymentItem> getBasicPaymentItems(PaymentContextRequest request);
}
