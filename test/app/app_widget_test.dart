import 'package:flutter_test/flutter_test.dart';
import 'package:spacematch_mvp/app/app.dart';
import 'package:spacematch_mvp/app/app_controller.dart';
import 'package:spacematch_mvp/data/app_store.dart';
import 'package:spacematch_mvp/data/generation_service.dart';

void main() {
  testWidgets('apresenta login com identidade Grafite & Areia', (tester) async {
    final controller = AppController(
      store: MemoryAppStore(),
      generator: const DemoGenerationService(),
    );
    await controller.initialize();
    await tester.pumpWidget(SpaceMatchApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('SpaceMatch'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.text('Space AI'), findsNothing);
  });
}
