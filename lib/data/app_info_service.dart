import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  const AppInfo({required this.version, required this.build});

  final String version;
  final String build;

  String get label {
    final name = version.trim();
    final number = build.trim();
    if (name.isEmpty) return 'Versão indisponível';
    return number.isEmpty ? name : '$name (build $number)';
  }
}

abstract final class AppInfoService {
  static Future<AppInfo> load() async {
    final package = await PackageInfo.fromPlatform();
    return AppInfo(version: package.version, build: package.buildNumber);
  }
}
