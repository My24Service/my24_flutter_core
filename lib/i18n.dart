import 'dart:io' show Platform;
import 'package:easy_localization/easy_localization.dart';

class My24i18n {
  final String basePath;

  My24i18n({
    required this.basePath
  }) ;

  static tr(String path, {Map<String, String>? namedArgs}) {
    final Map<String, String> envVars = Platform.environment;
    if (envVars['TESTING'] != null) {
      return "bla";
    }

    namedArgs ??= {};

    return path.tr(namedArgs: namedArgs);

  }

  String $trans(String key, {Map<String, String>? namedArgs, String? pathOverride}) {
    if (key.split('.').isNotEmpty) {
      return tr(key, namedArgs: namedArgs);
    }
    if (pathOverride != null) {
      return tr("$pathOverride.$key", namedArgs: namedArgs);
    }

    return tr("$basePath.$key", namedArgs: namedArgs);
  }
}
