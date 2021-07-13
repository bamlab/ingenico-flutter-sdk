import 'enum.dart';

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
  late List<PaymentProductField> fields;
}

class PaymentProductField {
  late String id;

  late Type type;

  /// Contains hints for rendering this field
  late DisplayHintsProductFields displayHints;

  /// Contains contraints for this field
  late DataRestrictions dataRestrictions;
}

class FormElement {
  late ListType type;
  late List<ValueMap> valueMapping;
}

class ValueMap {
  late String value;

  late List<PaymentProductFieldDisplayElement> displayElements;
}

class PaymentProductFieldDisplayElement {
  late String id;
  late PaymentProductFieldDisplayElementType type;
  late String value;
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

class DataRestrictions {
  late bool isRequired;

  late List<AbstractValidationRule> validationRules;
}

class AbstractValidationRule {
  late String messageId;

  // Validationtype
  late ValidationType type;
}
