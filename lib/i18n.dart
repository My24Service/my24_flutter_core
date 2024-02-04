abstract class My24i18n {
  final String basePath = "generic";
  static tr(String path, {Map<String, String>? namedArgs}) {}
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
