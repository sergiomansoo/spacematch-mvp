import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spacematch_mvp/data/app_info_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('usa a versão e build fornecidos pelo pacote instalado', () async {
    PackageInfo.setMockInitialValues(
      appName: 'SpaceMatch',
      packageName: 'com.sergiomanso.spacematch_mvp',
      version: '4.2.7',
      buildNumber: '93',
      buildSignature: '',
    );
    final info = await AppInfoService.load();
    expect(info.version, '4.2.7');
    expect(info.build, '93');
    expect(info.label, '4.2.7 (build 93)');
  });
}
