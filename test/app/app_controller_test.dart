import 'package:flutter_test/flutter_test.dart';
import 'package:spacematch_mvp/app/app_controller.dart';
import 'package:spacematch_mvp/data/app_store.dart';
import 'package:spacematch_mvp/data/generation_service.dart';
import 'package:spacematch_mvp/domain/models.dart';

void main() {
  test('voto repetido com operationId não duplica contagem', () async {
    final controller = AppController(
      store: MemoryAppStore(),
      generator: const DemoGenerationService(),
    );
    await controller.initialize();
    await controller.register(email: 'julia@exemplo.com', password: '123456');
    await controller.vote(
      roomId: controller.rooms.first.id,
      decision: VoteDecision.like,
      operationId: 'op-1',
    );
    await controller.vote(
      roomId: controller.rooms.first.id,
      decision: VoteDecision.like,
      operationId: 'op-1',
    );
    expect(controller.votes.length, 1);
    expect(controller.dna.evaluatedCount, 1);
    expect(controller.dna.revision, 1);
  });

  test('projeto gerado, salvo e reaberto persiste no store', () async {
    final store = MemoryAppStore();
    final first = AppController(
      store: store,
      generator: const DemoGenerationService(),
    );
    await first.initialize();
    await first.register(email: 'julia@exemplo.com', password: '123456');
    final project = await first.createProject(
      sourcePath: 'assets/images/room_01.jpg',
      roomType: 'Sala',
      description: 'Mais aconchegante',
      operationId: 'project-1',
    );
    await first.saveProject(project.id);
    final second = AppController(
      store: store,
      generator: const DemoGenerationService(),
    );
    await second.initialize();
    expect(second.projects, hasLength(1));
    expect(second.projects.single.status, ProjectStatus.succeeded);
    expect(second.projects.single.savedAt, isNotNull);
    expect(second.projects.single.resultAssetPath, isNotNull);
  });

  test('projeto falho pode ser retomado explicitamente', () async {
    final generator = _RecoveringGenerator();
    final controller = AppController(
      store: MemoryAppStore(),
      generator: generator,
    );
    await controller.initialize();
    await controller.register(email: 'julia@exemplo.com', password: '123456');
    final failed = await controller.createProject(
      sourcePath: 'assets/images/room_01.jpg',
      roomType: 'Sala',
      description: '',
      operationId: 'project-retry',
    );
    expect(failed.status, ProjectStatus.failed);

    final recovered = await controller.retryProject(failed.id);

    expect(recovered.status, ProjectStatus.succeeded);
    expect(generator.calls, 2);
  });
}

class _RecoveringGenerator implements GenerationService {
  int calls = 0;

  @override
  Future<String> generate(SpaceProject project) async {
    calls += 1;
    if (calls == 1) throw StateError('falha temporária');
    return 'assets/images/result_living.jpg';
  }
}
