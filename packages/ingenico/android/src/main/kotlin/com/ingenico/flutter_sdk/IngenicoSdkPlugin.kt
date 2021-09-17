package com.ingenico.flutter_sdk

import android.content.Context
import androidx.annotation.NonNull
import com.ingenico.direct.sdk.client.android.asynctask.BasicPaymentItemsAsyncTask.BasicPaymentItemsCallListener
import com.ingenico.direct.sdk.client.android.asynctask.PaymentProductAsyncTask
import com.ingenico.direct.sdk.client.android.communicate.C2sCommunicatorConfiguration
import com.ingenico.direct.sdk.client.android.model.*
import com.ingenico.direct.sdk.client.android.model.api.ErrorResponse
import com.ingenico.direct.sdk.client.android.model.paymentproduct.*
import com.ingenico.direct.sdk.client.android.model.paymentproduct.displayhints.DisplayHintsPaymentItem
import com.ingenico.direct.sdk.client.android.model.validation.ValidationRule
import com.ingenico.direct.sdk.client.android.session.Session
import com.ingenico.direct.sdk.client.android.session.SessionEncryptionHelper.OnPaymentRequestPreparedListener
import io.flutter.embedding.engine.plugins.FlutterPlugin


/** IngenicoSdkPlugin */
class IngenicoSdkPlugin : FlutterPlugin, Messages.Api {

    private val sessionsMap: HashMap<String, Session> = HashMap()
    private val paymentProductMap: HashMap<String, PaymentProduct> =
        HashMap()

    private var context: Context? = null


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Messages.Api.setup(flutterPluginBinding.binaryMessenger, this)
        context = flutterPluginBinding.applicationContext
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Messages.Api.setup(binding.binaryMessenger, null)
    }

    override fun createClientSession(arg: Messages.SessionRequest): Messages.SessionResponse {
        val session: Session = C2sCommunicatorConfiguration.initWithClientSessionId(
            arg.clientSessionId,
            arg.customerId,
            arg.clientApiUrl,
            arg.assetBaseUrl,
            arg.environmentIsProduction,
            arg.applicationIdentifier
        )

        val messageSession = Messages.SessionResponse()
        messageSession.sessionId = session.clientSessionId

        sessionsMap[messageSession.sessionId] = session

        return messageSession
    }

    override fun _passThrough(
        a: Messages.PaymentProductField?,
        b: Messages.BasicPaymentProduct?,
        c: Messages.AbstractValidationRule?,
        d: Messages.ValueMap?,
        e: Messages.PaymentProductFieldDisplayElement?
    ) {
    }

    private fun mapDisplayHints(displayHints: DisplayHintsPaymentItem): Messages.DisplayHintsPaymentItem {
        var mapped = Messages.DisplayHintsPaymentItem()
        mapped.displayOrder = displayHints.displayOrder.toLong()
        mapped.label = displayHints.label
        mapped.logoUrl = displayHints.logoUrl
        return mapped
    }

    private fun mapBasicPaymentProduct(basicPaymentProduct: BasicPaymentProduct): Messages.BasicPaymentProduct {
        var mapped = Messages.BasicPaymentProduct()
        mapped.allowsRecurring = basicPaymentProduct.allowsRecurring()
        mapped.allowsTokenization = basicPaymentProduct.allowsTokenization()
        mapped.displayHints = mapDisplayHints(basicPaymentProduct.displayHints)
        mapped.id = basicPaymentProduct.id
        mapped.maxAmount = basicPaymentProduct.maxAmount.toDouble()
        mapped.minAmount = basicPaymentProduct.minAmount.toDouble()
        mapped.paymentMethod = basicPaymentProduct.paymentMethod
        mapped.paymentProductGroup = basicPaymentProduct.paymentProductGroup
        mapped.usesRedirectionTo3rdParty = basicPaymentProduct.usesRedirectionTo3rdParty()

        return mapped;
    }

    private fun mapBasicPaymentItem(basicPaymentProduct: BasicPaymentItem): Messages.BasicPaymentProduct {
        var mapped = Messages.BasicPaymentProduct()
        mapped.displayHints = mapDisplayHints(basicPaymentProduct.displayHints)
        mapped.id = basicPaymentProduct.id

        return mapped;
    }


    private fun mapType(basicPaymentProduct: PaymentProductField.Type): Messages.Type {
        return when (basicPaymentProduct) {
            PaymentProductField.Type.STRING -> Messages.Type.string
            PaymentProductField.Type.INTEGER -> Messages.Type.integer
            PaymentProductField.Type.NUMERICSTRING -> Messages.Type.numericstring
            PaymentProductField.Type.EXPIRYDATE -> Messages.Type.expirydate
            PaymentProductField.Type.BOOLEAN -> Messages.Type.booleanEnum
            PaymentProductField.Type.DATE -> Messages.Type.date
        }
    }



    private fun mapPaymentProductField(paymentProductField: PaymentProductField): Messages.PaymentProductField {
        var mapped = Messages.PaymentProductField()
        mapped.id = paymentProductField.id
        mapped.type = mapType(paymentProductField.type)

        return mapped;
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

                val response = Messages.PaymentContextResponse()

                if (basicPaymentItems is BasicPaymentProducts) {
                    val basicPaymentProducts = basicPaymentItems as BasicPaymentProducts
                    response.basicPaymentProduct = basicPaymentProducts.basicPaymentProducts.map{
                        mapBasicPaymentProduct(it)
                    }
                    result.success(response)
                    return
                }
                response.basicPaymentProduct = basicPaymentItems.basicPaymentItems.map{
                    mapBasicPaymentItem(it)
                }
                result.success(response)

            }

            override fun onBasicPaymentItemsCallError(error: ErrorResponse) {
                throw Error(error.message)
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
                paymentProductMap[paymentProduct.id] = paymentProduct
                response.fields = paymentProduct.paymentProductFields.map { mapPaymentProductField(it) }
                result.success(response)
            }


            override fun onPaymentProductCallError(error: ErrorResponse) {
                throw Error(error.message)
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

    override fun preparePaymentRequest(
        arg: Messages.PaymentRequest,
        result: Messages.Result<Messages.PreparedPaymentRequest>
    ) {
        val paymentRequest = PaymentRequest()
        paymentRequest.paymentProduct = paymentProductMap[arg.paymentProductId]
        paymentRequest.tokenize = arg.tokenize
        arg.values.entries.forEach { e -> paymentRequest.setValue(e.key as String, e.value as String) }

        val listener =
            OnPaymentRequestPreparedListener { preparedPaymentRequest ->
                if (preparedPaymentRequest == null ||
                    preparedPaymentRequest.encryptedFields == null
                ) {
                    throw Error("Couldn't prepare the payment")
                } else {
                    val response = Messages.PreparedPaymentRequest()
                    response.encryptedFields = preparedPaymentRequest.encryptedFields
                    response.encodedClientMetaInfo = preparedPaymentRequest.encodedClientMetaInfo

                    result.success(response)
                }
            }

        val session = sessionsMap[arg.sessionId] ?: throw Error("Cannot find session")
        session.preparePaymentRequest(paymentRequest, context, listener)
    }
}
