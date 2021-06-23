import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of in_app_purchase must implement.
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
}
