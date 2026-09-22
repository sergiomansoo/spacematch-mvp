import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacematch_mvp/app/app_controller.dart';
import 'package:spacematch_mvp/core/design/space_theme.dart';
import 'package:spacematch_mvp/data/app_store.dart';
import 'package:spacematch_mvp/data/generation_service.dart';
import 'package:spacematch_mvp/domain/models.dart';
import 'package:spacematch_mvp/features/home/home_screen.dart';

void main() {
  testWidgets('Conta abre Sobre e retorna preservando a sessão e os votos', (
    tester,
  ) async {
    final controller = AppController(
      store: MemoryAppStore(),
      generator: const DemoGenerationService(),
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.register(email: 'julia@exemplo.com', password: '123456');
    await controller.vote(
      roomId: 'r1',
      decision: VoteDecision.like,
      operationId: 'about-test',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: SpaceTheme.dark,
        home: AccountScreen(controller: controller),
      ),
    );
    expect(find.text('Sobre o app'), findsOneWidget);
    expect(find.text('Conheça o SpaceMatch'), findsOneWidget);
    await tester.tap(find.text('Sobre o app'));
    await tester.pumpAndSettle();
    expect(find.text('Seu espaço, do seu jeito.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      ModalRoute.of(tester.element(find.text('Seu espaço, do seu jeito.')))
          ?.settings
          .name,
      '/about',
    );
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Conta'), findsOneWidget);
    expect(find.text('julia@exemplo.com'), findsOneWidget);
    expect(controller.isAuthenticated, isTrue);
    expect(controller.votes, {'r1': VoteDecision.like});
  });
}
