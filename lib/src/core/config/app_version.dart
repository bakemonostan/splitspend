/// Keep in sync with `pubspec.yaml` `version:` (e.g. 1.0.0+1 → v1.0.0, build 1).
abstract final class AppVersion {
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  static String get label => 'SplitSpend v$version (Build $buildNumber)';
}
