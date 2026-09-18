# Gates: SpaceMatch MVP Flutter

OWNS: **

Scope: aplicativo Flutter executável com fluxo local completo de autenticação, Match, SpaceDNA, transformação demonstrável, comparação e projetos persistidos

- [ ] G1: regras de domínio e widgets do fluxo MVP passam nos testes automatizados
  CHECK: flutter test
  EXPECT: All tests passed!
  EVIDENCE: pending

- [ ] G2: o código Flutter não possui diagnósticos estáticos
  CHECK: flutter analyze
  EXPECT: No issues found!
  EVIDENCE: pending

- [ ] G3: o aplicativo gera um APK Android de depuração instalável
  CHECK: flutter build apk --debug
  EXPECT: Built build\app\outputs\flutter-apk\app-debug.apk
  EVIDENCE: pending

- [ ] G4: o manifesto do produto cobre telas, rotas, persistência e ausência dos recursos pós-MVP
  CHECK: dart run tool/verify_mvp.dart
  EXPECT: MVP contract verification passed
  EVIDENCE: pending

