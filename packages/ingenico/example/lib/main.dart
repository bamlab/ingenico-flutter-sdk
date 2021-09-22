import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ingenico_sdk/ingenico_sdk.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Session? session;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;

    final response = await http.get(
      Uri.parse(
        "https://internal-recette.zonesecure.org/payment/init?pspid=DROUOTFLEXTEST",
      ),
    );

    final body = jsonDecode(response.body);

    final _session = await IngenicoSdk.initClientSession(
      applicationIdentifier: "Example Application/v1",
      clientSessionId: body["clientSessionId"],
      customerId: body["customerId"],
      assetBaseUrl: body["assetUrl"],
      clientApiUrl: body["clientApiUrl"],
      environmentIsProduction: false,
    );

    print("$_session");

    final basicPaymentProducts = await _session.getBasicPaymentProducts(
      countryCode: "FR",
      currencyCode: "EUR",
      isRecurring: false,
      amountValue: 200000,
    );

    print(basicPaymentProducts);

    final basicPaymentProduct = await _session.getPaymentProduct(
      paymentProductId: "1",
      amountValue: 200000,
      currencyCode: "EUR",
      countryCode: "FR",
      isRecurring: false,
    );

    print(basicPaymentProduct);

    final preparedPayment = await _session.preparePaymentRequest(
      paymentProductId: basicPaymentProduct.id!,
      values: {
        "cardNumber": "4111111111111111",
        "cardholderName": "Guillaume Bernos",
        "expiryDate": "02/2022",
        "cvv": "911",
      },
      currencyCode: 'EUR',
      tokenize: true,
    );

    print(preparedPayment);

    setState(() {
      session = _session;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: ${session?.sessionId}'),
        ),
      ),
    );
  }
}
