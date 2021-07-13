import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/types.dart';

export 'src/enum.dart';
export 'src/types.dart';

/// The interface that implementations of ingenico_sdk must implement.
///
/// Platform implementations should extend this class rather than implement it as `ingenico`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [IngenicoPlatform] methods.
abstract class IngenicoPlatform extends PlatformInterface {
  /// Constructs a IngenicoPlatform.
  IngenicoPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The instance of [IngenicoPlatform] to use.
  ///
  /// Must be set before accessing.
  static IngenicoPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [IngenicoPlatform] when they register themselves.
  static set instance(IngenicoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Should only be accessed after setter is called.
  static late IngenicoPlatform _instance;

  /// Convenience method for creating Session given the clientSessionId, customerId and region
  static Future<SessionPlatform> initClientSession(
      {required String clientSessionId,
      required String customerId,
      required String clientApiUrl,
      required String assetBaseUrl,
      required bool environmentIsProduction,
      required String applicationIdentifier}) async {
    throw UnimplementedError();
  }
}

/// The interface that implementations of ingenico_sdk must implement.
///
/// Platform implementations should extend this class rather than implement it as `ingenico`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [SessionPlatform] methods.
abstract class SessionPlatform extends PlatformInterface {
  /// Constructs a IngenicoPlatform.
  SessionPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The instance of [SessionPlatform] to use.
  ///
  /// Must be set before accessing.
  static SessionPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [IngenicoPlatform] when they register themselves.
  static set instance(SessionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Should only be accessed after setter is called.
  static late SessionPlatform _instance;

  /// Gets all basicPaymentItems for a given payment context
  Future<List<BasicPaymentProduct>> getBasicPaymentProducts(
      {required double amountValue,
      required String currencyCode,
      required String countryCode,
      required bool isRecurring}) async {
    throw UnimplementedError();
  }

  /// Gets PaymentProduct with fields from the GC gateway
  Future<PaymentProduct> getPaymentProduct(
      {required String paymentProductId,
      required double amountValue,
      required String currencyCode,
      required String countryCode,
      required bool isRecurring}) async {
    throw UnimplementedError();
  }
}
