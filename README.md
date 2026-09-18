# SpaceMatch MVP

Aplicativo Flutter para descobrir preferências de interiores, transformar uma foto e guardar projetos. A interface segue o conceito **Grafite & Areia** criado para o SpaceMatch, com navegação e textos em português.

## Fluxo implementado

1. Criar conta, entrar, recuperar acesso, sair e excluir os dados locais.
2. Avaliar ambientes por gesto ou botões.
3. Consultar o SpaceDNA calculado por uma regra determinística e testada.
4. Fotografar ou escolher uma imagem, selecionar o cômodo e escrever o briefing.
5. Abrir a proposta, comparar antes/depois com controle vertical e salvar.
6. Fechar e reabrir o app com sessão, votos e projetos preservados no dispositivo.

## Executar

Requisitos: Flutter compatível com Dart 3.13 ou superior e um emulador/dispositivo Android ou iOS.

```bash
flutter pub get
flutter run
```

Validação usada neste repositório:

```bash
flutter test
flutter analyze
flutter build apk --debug
dart run tool/verify_mvp.dart
```

O APK de desenvolvimento é criado em `build/app/outputs/flutter-apk/app-debug.apk`.

## Arquitetura

- `lib/app`: composição do aplicativo e controlador de estado.
- `lib/domain`: modelos e cálculo auditável do SpaceDNA.
- `lib/data`: persistência local, mídia e contrato de geração.
- `lib/features`: conta, Home, Match, DNA, criação e projetos.
- `test`: testes de domínio, idempotência, persistência e identidade visual.

O estado usa `ChangeNotifier`, dados imutáveis e dependências injetadas por construtor. Votos e criação aceitam chaves de operação para impedir duplicações lógicas.

## Limite desta entrega executável

Esta versão roda sem chaves externas: autenticação e dados ficam no dispositivo, e a geração usa três propostas visuais incluídas no app por meio de `DemoGenerationService`. Isso permite validar todo o fluxo e o design, mas não oferece isolamento entre aparelhos nem geração real por IA.

Para produção, implemente os contratos `AppStore` e `GenerationService` com o backend descrito na spec, provedor de autenticação, storage privado e worker assíncrono. Senhas da conta demonstrativa não devem ser tratadas como credenciais de produção. As fotografias herdadas do protótipo precisam de validação de licença antes da distribuição pública.

## Dependência fixada

`path_provider_foundation` está fixado em `2.4.1`: a linha 2.6 usa hooks nativos que falham quando o Flutter SDK está instalado em um caminho com espaços no Windows. O override pode ser removido quando esse ambiente ou o pacote deixar de apresentar a incompatibilidade.
