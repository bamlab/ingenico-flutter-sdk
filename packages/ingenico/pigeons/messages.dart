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

class GetPaymentProductRequest {
  late String sessionId;
  late String paymentProductId;
  late double amountValue;
  late String currencyCode;
  late String countryCode;
  late bool isRecurring;
}

class PaymentContextResponse {
  late List<BasicPaymentProduct?> basicPaymentProduct;
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

/// Cannot extend in Pigeon Classes
class PaymentProduct {
  late String id;
  late String? paymentMethod;
  late String? paymentProductGroup;
  late double? minAmount;
  late double? maxAmount;
  late bool? allowsRecurring;
  late bool? allowsTokenization;
  late bool? usesRedirectionTo3rdParty;
  late DisplayHintsPaymentItem displayHints;
  late List<PaymentProductField?> fields;
}

class PaymentProductField {
  late String id;

  // Type of this field for GC gateway
  late Type type;

  // Contains hints for rendering this field
  late DisplayHintsProductFields displayHints;

  // Contains contraints for this field
  late DataRestrictions dataRestrictions;
}

enum Type {
  string,
  integer,
  numericstring,
  expirydate,
  // To Prevent Collision
  booleanEnum,
  date,
}

enum PreferredInputType {
  integerKeyboard,
  stringKeyboard,
  phoneNumberKeyboard,
  emailAddressKeyboard,
  dateKeyboard
}

class DisplayHintsProductFields {
  late bool alwaysShow;
  late bool obfuscate;
  late int displayOrder;
  late String label;
  late String placeholderLabel;
  late String link;
  late String mask;
  late PreferredInputType preferredInputType;
  late Tooltip tooltip;
  late FormElement formElement;
}

class Tooltip {
  late String image;
  late String label;
}

enum ListType {
  text,
  list,
  currency,
  date,
  booleanEnum,
}

class FormElement {
  late ListType type;
  late List<ValueMap?> valueMapping;
}

class ValueMap {
  late String value;

  late List<PaymentProductFieldDisplayElement?> displayElements;
}

class PaymentProductFieldDisplayElement {
  late String id;
  late PaymentProductFieldDisplayElementType type;
  late String value;
}

enum PaymentProductFieldDisplayElementType {
  integer,
  string,
  currency,
  percentage,
  uri,
}

enum ValidationType {
  expirationDate,
  emailAdress,
  fixedList,
  iban,
  length,
  luhn,
  range,
  regularExpression,
  type,
  termsAndConditions,
}

class DataRestrictions {
  late bool isRequired;

  late List<AbstractValidationRule?> validationRules;
}

class AbstractValidationRule {
  late String messageId;

  // Validationtype
  late ValidationType type;
}

class PaymentRequest {
  late Map<String?, String?> values;
  late String paymentProductId;
  late bool tokenize;
  late String sessionId;
}

class PreparedPaymentRequest {
  late String encryptedFields;
  late String encodedClientMetaInfo;
}

@HostApi()
abstract class Api {
  SessionResponse initClientSession(SessionRequest request);

  // For proper object generation
  // ignore: unused_element
  void _passThrough(
      PaymentProductField a,
      BasicPaymentProduct b,
      AbstractValidationRule c,
      ValueMap d,
      PaymentProductFieldDisplayElement e);

  @async
  PaymentContextResponse getBasicPaymentItems(PaymentContextRequest request);

  @async
  PaymentProduct getPaymentProduct(GetPaymentProductRequest request);

  @async
  PreparedPaymentRequest preparePaymentRequest(PaymentRequest request);
}
