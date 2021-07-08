package com.ingenico.flutter_sdk

import androidx.annotation.NonNull
import com.ingenico.direct.sdk.client.android.communicate.C2sCommunicatorConfiguration
import com.ingenico.direct.sdk.client.android.model.AmountOfMoney
import com.ingenico.direct.sdk.client.android.model.paymentproduct.BasicPaymentItems
import com.ingenico.direct.sdk.client.android.session.Session
import io.flutter.embedding.engine.plugins.FlutterPlugin


/** IngenicoSdkPlugin */
class IngenicoSdkPlugin: FlutterPlugin, Messages.Api {

  private val sessionsMap : HashMap<String, Session>
          = HashMap<String, Session> ()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Messages.Api.setup(flutterPluginBinding.binaryMessenger, this)
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    Messages.Api.setup(binding.binaryMessenger, null)
  }

  override fun initClientSession(arg: Messages.SessionRequest): Messages.Session {
    val session: Session = C2sCommunicatorConfiguration.initWithClientSessionId(
      arg.clientSessionId,
      arg.customerId,
      arg.clientApiUrl,
      arg.assetBaseUrl,
      arg.environmentIsProduction,
      arg.applicationIdentifier
    )

    val messageSession = Messages.Session();
    messageSession.sessionId = session.clientSessionId;

    sessionsMap[messageSession.sessionId] = session;

    BasicPaymentItems()

    return messageSession;
  }
}
