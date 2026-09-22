import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/app_controller.dart';
import 'data/app_store.dart';
import 'data/generation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController(
    store: PreferencesAppStore(),
    generator: const DemoGenerationService(delay: Duration(milliseconds: 900)),
  );
  await controller.initialize();
  runApp(SpaceMatchApp(controller: controller, isDemo: true));
}
