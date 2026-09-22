import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacematch_mvp/core/design/space_theme.dart';
import 'package:spacematch_mvp/data/app_info_service.dart';
import 'package:spacematch_mvp/features/about/about_screen.dart';

void main() {
  Widget app({required Future<AppInfo> Function() load, bool isDemo = true}) =>
      MaterialApp(
        theme: SpaceTheme.dark,
        home: AboutScreen(loadAppInfo: load, isDemo: isDemo),
      );

  testWidgets('mostra conteúdo e lê a versão apenas uma vez por abertura', (
    tester,
  ) async {
    final result = Completer<AppInfo>();
    var calls = 0;
    Future<AppInfo> load() {
      calls++;
      return result.future;
    }

    await tester.pumpWidget(app(load: load));
    expect(find.text('Carregando versão…'), findsOneWidget);
    expect(find.text('Como funciona'), findsOneWidget);
    expect(find.text('Match'), findsOneWidget);
    expect(find.text('SpaceDNA'), findsOneWidget);
    expect(find.text('Projetos'), findsOneWidget);
    expect(find.text('Sobre esta versão'), findsOneWidget);
    result.complete(const AppInfo(version: '2.3.4', build: '87'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(app(load: load));
    expect(find.text('2.3.4 (build 87)'), findsOneWidget);
    expect(calls, 1);
    expect(
      Theme.of(tester.element(find.text('Como funciona')))
          .scaffoldBackgroundColor,
      SpaceColors.canvas,
    );
  });

  for (final info in [
    const AppInfo(version: '2.0.0', build: ''),
    const AppInfo(version: ' ', build: '9'),
  ]) {
    testWidgets('metadados incompletos: ${info.version}/${info.build}', (
      tester,
    ) async {
      await tester.pumpWidget(app(load: () async => info));
      await tester.pumpAndSettle();
      expect(
        find.text(
          info.version.trim().isEmpty ? 'Versão indisponível' : '2.0.0',
        ),
        findsOneWidget,
      );
    });
  }

  testWidgets('erro de versão não impede abrir licenças e voltar', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(load: () async => throw StateError('metadados')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Versão indisponível'), findsOneWidget);
    await tester.ensureVisible(find.text('Licenças de código aberto'));
    await tester.tap(find.text('Licenças de código aberto'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Voltar'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Versão indisponível'), findsOneWidget);
    expect(find.byType(AboutScreen), findsOneWidget);
  });

  testWidgets('configuração não demonstrativa omite aviso demonstrativo', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        load: () async => const AppInfo(version: '1', build: '2'),
        isDemo: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sobre esta versão'), findsNothing);
  });

  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(600, 900),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Sobre acessível em $size com escala $scale', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: SpaceTheme.dark,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: AboutScreen(
              loadAppInfo: () async =>
                  const AppInfo(version: '1.0.0', build: '1'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Licenças de código aberto'));
        await tester.tap(find.text('Licenças de código aberto'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Voltar'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
