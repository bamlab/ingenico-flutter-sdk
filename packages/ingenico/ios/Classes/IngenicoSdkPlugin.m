#import "IngenicoSdkPlugin.h"
#if __has_include(<ingenico_sdk/ingenico_sdk-Swift.h>)
#import <ingenico_sdk/ingenico_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ingenico_sdk-Swift.h"
#endif

@implementation IngenicoSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIngenicoSdkPlugin registerWithRegistrar:registrar];
}
@end
