package com.ingenico.flutter_sdk

import android.content.Context
import androidx.annotation.NonNull
import com.ingenico.direct.sdk.client.android.asynctask.BasicPaymentItemsAsyncTask.BasicPaymentItemsCallListener
import com.ingenico.direct.sdk.client.android.asynctask.PaymentProductAsyncTask
import com.ingenico.direct.sdk.client.android.asynctask.PaymentProductAsyncTask.OnPaymentProductCallCompleteListener
import com.ingenico.direct.sdk.client.android.communicate.C2sCommunicatorConfiguration
import com.ingenico.direct.sdk.client.android.model.AmountOfMoney
import com.ingenico.direct.sdk.client.android.model.CountryCode
import com.ingenico.direct.sdk.client.android.model.CurrencyCode
import com.ingenico.direct.sdk.client.android.model.PaymentContext
import com.ingenico.direct.sdk.client.android.model.api.ErrorResponse
import com.ingenico.direct.sdk.client.android.model.paymentproduct.BasicPaymentItems
import com.ingenico.direct.sdk.client.android.model.paymentproduct.BasicPaymentProducts
import com.ingenico.direct.sdk.client.android.model.paymentproduct.PaymentProduct
import com.ingenico.direct.sdk.client.android.session.Session
import io.flutter.embedding.engine.plugins.FlutterPlugin


/** IngenicoSdkPlugin */
class IngenicoSdkPlugin : FlutterPlugin, Messages.Api {

    private val sessionsMap: HashMap<String, Session> = HashMap<String, Session>()

    private var context: Context? = null


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Messages.Api.setup(flutterPluginBinding.binaryMessenger, this)
        context = flutterPluginBinding.applicationContext
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Messages.Api.setup(binding.binaryMessenger, null)
    }

    override fun initClientSession(arg: Messages.SessionRequest): Messages.SessionResponse {
        val session: Session = C2sCommunicatorConfiguration.initWithClientSessionId(
            arg.clientSessionId,
            arg.customerId,
            arg.clientApiUrl,
            arg.assetBaseUrl,
            arg.environmentIsProduction,
            arg.applicationIdentifier
        )

        val messageSession = Messages.SessionResponse();
        messageSession.sessionId = session.clientSessionId;

        sessionsMap[messageSession.sessionId] = session;

        return messageSession;
    }

    override fun getBasicPaymentItems(
        arg: Messages.PaymentContextRequest,
        result: Messages.Result<Messages.PaymentContextResponse>
    ) {
        val amountValue: Long = arg.amountValue.toLong()
        val currencyCode = CurrencyCode.valueOf(arg.currencyCode)
        val amountOfMoney = AmountOfMoney(amountValue, currencyCode)
        val countryCode = CountryCode.valueOf(arg.countryCode)
        val isRecurring = arg.isRecurring

        val paymentContext = PaymentContext(amountOfMoney, countryCode, isRecurring)

        val listener: BasicPaymentItemsCallListener = object : BasicPaymentItemsCallListener {
            override fun onBasicPaymentItemsCallComplete(basicPaymentItems: BasicPaymentItems) {

                var response = Messages.PaymentContextResponse()
                if (basicPaymentItems is BasicPaymentProducts) {
                    val basicPaymentProducts = basicPaymentItems as BasicPaymentProducts
                    response.basicPaymentProduct =
                        basicPaymentProducts.basicPaymentProducts as List<Any>?
                    result.success(response)
                    return
                }

                response.basicPaymentProduct = basicPaymentItems.basicPaymentItems as List<Any>?
                result.success(response)
            }

            override fun onBasicPaymentItemsCallError(error: ErrorResponse) {
                throw Error(error.message);
            }
        }

        val session = sessionsMap[arg.sessionId] ?: throw Error("Cannot find session")
        session.getBasicPaymentItems(context, paymentContext, listener, false)

    }

    override fun getPaymentProduct(
        arg: Messages.GetPaymentProductRequest,
        result: Messages.Result<Messages.PaymentProduct>
    ) {

        val listener: PaymentProductAsyncTask.PaymentProductCallListener = object :
            PaymentProductAsyncTask.PaymentProductCallListener {
            override fun onPaymentProductCallComplete(paymentProduct: PaymentProduct) {
                val response = Messages.PaymentProduct()
                response.fields = paymentProduct.paymentProductFields as List<Any>?
                result.success(response)
            }


            override fun onPaymentProductCallError(error: ErrorResponse) {
                throw Error(error.message);
            }
        }

        val amountValue: Long = arg.amountValue.toLong()
        val currencyCode = CurrencyCode.valueOf(arg.currencyCode)
        val amountOfMoney = AmountOfMoney(amountValue, currencyCode)
        val countryCode = CountryCode.valueOf(arg.countryCode)
        val isRecurring = arg.isRecurring

        val paymentContext = PaymentContext(amountOfMoney, countryCode, isRecurring)

        val session = sessionsMap[arg.sessionId] ?: throw Error("Cannot find session")

        session.getPaymentProduct(context, arg.paymentProductId, paymentContext, listener)
    }
}
