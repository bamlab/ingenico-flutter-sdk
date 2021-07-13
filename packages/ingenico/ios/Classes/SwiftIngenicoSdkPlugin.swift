import Flutter
import UIKit
import IngenicoConnectKit

public class SwiftIngenicoSdkPlugin: NSObject, FlutterPlugin, FLTApi {
    
    private var sessionsMap = [String : Session]()
    private var paymentProductMap = [String : PaymentProduct]()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let api : FLTApi = SwiftIngenicoSdkPlugin.init()
        FLTApiSetup(messenger, api);
      }
 
    public func initClientSession(clientSession input: FLTSessionRequest, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> FLTSessionResponse {
        let session = Session(clientSessionId: input.clientSessionId!, customerId: input.customerId!,
                              baseURL: input.clientApiUrl!, assetBaseURL: input.assetBaseUrl!, appIdentifier: input.applicationIdentifier!)

        sessionsMap[session.clientSessionId] = session
        let response = FLTSessionResponse();
        response.sessionId = session.clientSessionId
        return response
    }
    
    public func getBasicPaymentItems(_ input: FLTPaymentContextRequest?, completion: @escaping (FLTPaymentContextResponse?, FlutterError?) -> Void) {
        let amountOfMoney = PaymentAmountOfMoney(totalAmount: Int(truncating: input!.amountValue!), currencyCode: CurrencyCode(rawValue: input!.currencyCode!)!)
        let context = PaymentContext(amountOfMoney: amountOfMoney, isRecurring: input!.isRecurring! as! Bool,
                                     countryCode: CountryCode(rawValue: input!.countryCode!)!)
        
        let session = sessionsMap[input!.sessionId!]!
        session.paymentItems(for: context, groupPaymentProducts: false,
                                    success: { paymentItems in
            let response = FLTPaymentContextResponse()

            response.basicPaymentProduct = paymentItems.allPaymentItems as [Any]
            completion(response,  nil)
        }, failure: { error in
            let error = FlutterError(code: "ERROR", message: error.localizedDescription, details: nil)
            completion(nil,  error)
        })
    }
    
    public func getPaymentProduct(_ input: FLTGetPaymentProductRequest?, completion: @escaping (FLTPaymentProduct?, FlutterError?) -> Void) {
        let paymentProductId = input!.paymentProductId!
        let amountOfMoney = PaymentAmountOfMoney(totalAmount: Int(truncating: input!.amountValue!), currencyCode: CurrencyCode(rawValue: input!.currencyCode!)!)
        let context = PaymentContext(amountOfMoney: amountOfMoney, isRecurring: input!.isRecurring! as! Bool,
                                     countryCode: CountryCode(rawValue: input!.countryCode!)!)

        let session = sessionsMap[input!.sessionId!]!

        session.paymentProduct(withId: paymentProductId, context: context,
                                    success: { paymentProduct in
            let response = FLTPaymentProduct()

            response.fields = paymentProduct.fields.paymentProductFields as [Any]
            completion(response,  nil)
        }, failure: { error in
            // Indicate that an error has occurred.
        })

    }
    
    public func preparePaymentRequest(_ input: FLTPaymentRequest?, completion: @escaping (FLTPreparedPaymentRequest?, FlutterError?) -> Void) {
        <#code#>
    }

}
