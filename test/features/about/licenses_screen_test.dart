import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacematch_mvp/core/design/space_theme.dart';
import 'package:spacematch_mvp/features/about/licenses_screen.dart';

void main() {
  Widget app(Future<List<LicenseEntry>> Function() load) => MaterialApp(
    theme: SpaceTheme.dark,
    home: LicensesScreen(loadLicenses: load),
  );

  testWidgets('mostra carregamento e textos completos de todos os pacotes', (
    tester,
  ) async {
    final result = Completer<List<LicenseEntry>>();
    await tester.pumpWidget(app(() => result.future));
    expect(find.text('Carregando licenças…'), findsOneWidget);
    result.complete([
      LicenseEntryWithLineBreaks([
        'pacote_a',
        'pacote_b',
      ], 'Copyright exemplo\n\nTexto integral da licença.'),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('pacote_a, pacote_b'), findsOneWidget);
    expect(find.text('Copyright exemplo'), findsOneWidget);
    expect(find.text('Texto integral da licença.'), findsOneWidget);
  });

  testWidgets('registro vazio tem mensagem em português', (tester) async {
    await tester.pumpWidget(app(() async => []));
    await tester.pumpAndSettle();
    expect(
      find.text('Nenhuma licença disponível nesta versão.'),
      findsOneWidget,
    );
  });

  testWidgets('falha permite tentar novamente e recuperar o conteúdo', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      app(() async {
        if (attempts++ == 0) throw StateError('registro indisponível');
        return [
          LicenseEntryWithLineBreaks(['pacote'], 'Licença recuperada'),
        ];
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível carregar as licenças.'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Licença recuperada'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('licença longa é rolável a 200% em tela estreita', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: SpaceTheme.dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: LicensesScreen(
          loadLicenses: () async => [
            LicenseEntryWithLineBreaks(
              ['pacote_com_nome_muito_longo'],
              '${List.filled(30, 'Texto da licença.').join('\n\n')}\n\nFim da licença.',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final title = tester.renderObject<RenderParagraph>(
      find.text('Licenças de código aberto'),
    );
    expect(title.textScaler.scale(10), 20);
    expect(title.didExceedMaxLines, isFalse);
    await tester.ensureVisible(find.text('Fim da licença.'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Fim da licença.').hitTestable(), findsOneWidget);
  });
}
