import '../domain/models.dart';

abstract interface class GenerationService {
  Future<String> generate(SpaceProject project);
}

class DemoGenerationService implements GenerationService {
  const DemoGenerationService({this.delay = Duration.zero});

  final Duration delay;

  @override
  Future<String> generate(SpaceProject project) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return switch (project.roomType) {
      'Quarto' => 'assets/images/result_bedroom.jpg',
      'Cozinha' => 'assets/images/result_kitchen.jpg',
      _ => 'assets/images/result_living.jpg',
    };
  }
}
