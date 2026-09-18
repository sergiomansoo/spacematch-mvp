# SpaceMatch MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Entregar um aplicativo Flutter demonstrável para autenticar localmente, avaliar referências, calcular SpaceDNA, transformar uma foto, comparar, salvar e reabrir projetos.

**Architecture:** Aplicativo offline-first de demonstração com estado imutável, ChangeNotifier, persistência JSON e serviços injetáveis. GenerationService delimita a futura integração real.

**Tech Stack:** Flutter, Dart null safety, Material 3, shared_preferences, image_picker e testes Flutter.

## Global Constraints

- Usar somente o design Grafite & Areia.
- Incluir conta, Match, SpaceDNA, transformação, comparação e projetos.
- Excluir chat, 3D, grafo, favoritos, Google Login e criação do zero.
- Informar que o gerador local é demonstrável e substituível.
- Usar SafeArea, alvos de 48 dp e layouts de 375 e 390 dp.

### Task 1: Fundação visual

**Files:** pubspec.yaml, lib/main.dart, lib/app/**, lib/core/design/**, test/core/design/**

**Interfaces:** SpaceTheme, AppController, AppRoute e componentes base.

- [ ] Criar teste de tema/rotas e observar falha.
- [ ] Implementar tema, shell, rotas e componentes.
- [ ] Rodar teste e confirmar sucesso.

### Task 2: Domínio e persistência

**Files:** lib/domain/**, lib/data/**, test/domain/**, test/data/**

**Interfaces:** modelos, DnaCalculator, LocalAppRepository e GenerationService.

- [ ] Criar testes de DNA, idempotência e persistência; confirmar falha.
- [ ] Implementar o necessário para os testes.
- [ ] Rodar testes e refatorar mantendo verde.

### Task 3: Conta, Match e SpaceDNA

**Files:** lib/features/auth/**, lib/features/match/**, lib/features/dna/**, test/features/**

**Interfaces:** telas de conta, Match e DNA ligadas ao controller.

- [ ] Criar widget tests de validação, voto e perfil; confirmar falha.
- [ ] Implementar telas e estados.
- [ ] Rodar testes e confirmar navegação.

### Task 4: Home, transformação e projetos

**Files:** lib/features/home/**, lib/features/create/**, lib/features/projects/**, test/features/**, assets/images/**

**Interfaces:** formulário, geração local injetável, comparador e lista persistida.

- [ ] Criar testes de geração, comparação e reabertura; confirmar falha.
- [ ] Implementar Home, Criar, Projetos e Resultado.
- [ ] Rodar testes e confirmar fluxo.

### Task 5: Verificação e entrega

**Files:** README.md, tool/verify_mvp.dart, configurações e CI.

**Interfaces:** documentação, verificador do contrato e APK.

- [ ] Implementar verificador do contrato MVP.
- [ ] Executar format, analyze, tests, verificador e build.
- [ ] Criar commits e publicar repositório privado no GitHub quando autenticado.
