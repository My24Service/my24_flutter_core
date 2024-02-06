import 'dart:io' show Platform;
import 'package:easy_localization/easy_localization.dart';
import 'package:logging/logging.dart';

final log = Logger('core.i18n');

class My24i18n {
  final String basePath;

  My24i18n({
    required this.basePath,
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
    if (key.split('.').length > 1) {
      log.info("using translation by direct path: $key (${key.split('.')}");
      return tr(key, namedArgs: namedArgs);
    }
    if (pathOverride != null) {
      log.info("using translation by path override: $pathOverride.$key");
      return tr("$pathOverride.$key", namedArgs: namedArgs);
    }
    log.info("using translation by base path: $basePath.$key");

    return tr("$basePath.$key", namedArgs: namedArgs);
  }
}
