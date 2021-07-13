A plugin to use Ingenico in Flutter apps.

This plugin supports Android and iOS.

## Features

Use this plugin in your Flutter app to:

## Getting started

This plugin uses [Pigeon](https://pub.dev/packages/pigeon) in order to generate platform channels type safe interfaces.

Warning: While it's very useful, Pigeon is still in early development, please check for breaking changes before regeneration code!

You should first put your new types in the `pigeons/messages.dart` file and then launch the following command:

```bash
flutter pub run pigeon \
  --input pigeons/messages.dart \
  --dart_out lib/pigeon.dart \
  --objc_header_out ios/Classes/Messages.h \
  --objc_source_out ios/Classes/Messages.m \
  --objc_prefix FLT \
  --java_out ./android/src/main/java/com/ingenico/flutter_sdk/Messages.java \
  --java_package "com.ingenico.flutter_sdk"
```

It will regenerate the correct informations in the 2 platforms.
