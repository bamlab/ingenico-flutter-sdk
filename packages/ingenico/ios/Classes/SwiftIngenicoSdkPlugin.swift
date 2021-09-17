import Flutter
import IngenicoConnectKit
import UIKit

public class SwiftIngenicoSdkPlugin: NSObject, FlutterPlugin, FLTApi {
    public func _passThroughA(_ a: FLTPaymentProductField, b: FLTBasicPaymentProduct, c: FLTAbstractValidationRule, d: FLTValueMap, e: FLTPaymentProductFieldDisplayElement, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {}

    private var sessionsMap = [String: Session]()
    private var paymentProductMap = [String: PaymentProduct]()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger: FlutterBinaryMessenger = registrar.messenger()
        let api: FLTApi & NSObjectProtocol = SwiftIngenicoSdkPlugin()
        FLTApiSetup(messenger, api)
    }

    public func createClientSessionRequest(_ input: FLTSessionRequest, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> FLTSessionResponse? {
        let session = Session(clientSessionId: input.clientSessionId!, customerId: input.customerId!,
                              baseURL: input.clientApiUrl!, assetBaseURL: input.assetBaseUrl!, appIdentifier: input.applicationIdentifier!)

        sessionsMap[session.clientSessionId] = session
        let response = FLTSessionResponse()
        response.sessionId = session.clientSessionId
        return response
    }

    private func mapDisplayHints(displayHints: PaymentItemDisplayHints) -> FLTDisplayHintsPaymentItem {
        let mapped = FLTDisplayHintsPaymentItem()
        mapped.displayOrder = NSNumber(value: displayHints.displayOrder!)
        mapped.logoUrl = displayHints.logoPath
        return mapped
    }

    private func mapBasicPaymentItem(basicPaymentProduct: BasicPaymentItem) -> FLTBasicPaymentProduct {
        let mapped = FLTBasicPaymentProduct()
        mapped.displayHints = mapDisplayHints(displayHints: basicPaymentProduct.displayHints)
        mapped.id = basicPaymentProduct.identifier

        return mapped
    }

    private func mapType(type: FieldType) -> FLTType {
        switch type {
        case .string:
            return FLTType.string
        case .integer:
            return FLTType.string

        case .expirationDate:
            return FLTType.expirydate

        case .numericString:
            return FLTType.numericstring

        case .boolString:
            return FLTType.booleanEnum

        case .dateString:
            return FLTType.date
        }
    }

    private func mapPaymentProductField(paymentProductField: PaymentProductField) -> FLTPaymentProductField {
        let mapped = FLTPaymentProductField()
        mapped.id = paymentProductField.identifier
        mapped.type = mapType(type: paymentProductField.type)

        return mapped
    }

    public func getBasicPaymentItemsRequest(_ input: FLTPaymentContextRequest?, completion: @escaping (FLTPaymentContextResponse?, FlutterError?) -> Void) {
        let amountOfMoney = PaymentAmountOfMoney(totalAmount: Int(truncating: input!.amountValue!), currencyCode: CurrencyCode(rawValue: input!.currencyCode!)!)
        let context = PaymentContext(amountOfMoney: amountOfMoney, isRecurring: input!.isRecurring! as! Bool,
                                     countryCode: CountryCode(rawValue: input!.countryCode!)!)

        let session = sessionsMap[input!.sessionId!]!
        // TODO: add a parameter to handle the groupPaymentProducts parameter
        session.paymentItems(for: context, groupPaymentProducts: false,
                             success: { paymentItems in
                                 let response = FLTPaymentContextResponse()

                                 response.basicPaymentProduct = paymentItems.allPaymentItems.map(self.mapBasicPaymentItem)
                                 completion(response, nil)
                             }, failure: { error in
                                 let error = FlutterError(code: "ERROR", message: error.localizedDescription, details: nil)
                                 completion(nil, error)
                             })
    }

    public func getPaymentProductRequest(_ input: FLTGetPaymentProductRequest?, completion: @escaping (FLTPaymentProduct?, FlutterError?) -> Void) {
        let paymentProductId = input!.paymentProductId!
        let amountOfMoney = PaymentAmountOfMoney(totalAmount: Int(truncating: input!.amountValue!), currencyCode: CurrencyCode(rawValue: input!.currencyCode!)!)
        let context = PaymentContext(amountOfMoney: amountOfMoney, isRecurring: input!.isRecurring! as! Bool,
                                     countryCode: CountryCode(rawValue: input!.countryCode!)!)

        let session = sessionsMap[input!.sessionId!]!

        session.paymentProduct(withId: paymentProductId, context: context,
                               success: { paymentProduct in
                                   let response = FLTPaymentProduct()

                                   response.fields = paymentProduct.fields.paymentProductFields.map(self.mapPaymentProductField)
                                   completion(response, nil)
                               }, failure: { error in
                                   let error = FlutterError(code: "ERROR", message: error.localizedDescription, details: nil)
                                   completion(nil, error)
                               })
    }

    public func preparePaymentRequest(_ input: FLTPaymentRequest?, completion: @escaping (FLTPreparedPaymentRequest?, FlutterError?) -> Void) {
        let paymentProduct = paymentProductMap[input!.paymentProductId!]!

        let paymentRequest = PaymentRequest(paymentProduct: paymentProduct, accountOnFile: nil, tokenize: input!.tokenize! as? Bool)

        input!.values!.forEach { (key: AnyHashable, value: Any) in
            paymentRequest.setValue(forField: value as! String, value: key as! String)
        }
        let session = sessionsMap[input!.sessionId!]!

        session.prepare(paymentRequest, success: { preparedPaymentRequest in
            let response = FLTPreparedPaymentRequest()
            response.encryptedFields = preparedPaymentRequest.encryptedFields
            response.encodedClientMetaInfo = preparedPaymentRequest.encodedClientMetaInfo

            completion(response, nil)
        }, failure: { error in
            let error = FlutterError(code: "ERROR", message: error.localizedDescription, details: nil)
            completion(nil, error)
        })
    }
}
