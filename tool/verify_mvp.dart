import 'dart:io';

void main() {
  final requiredFiles = <String>[
    'lib/features/auth/auth_screen.dart',
    'lib/features/match/match_screen.dart',
    'lib/features/dna/dna_screen.dart',
    'lib/features/create/create_screen.dart',
    'lib/features/projects/projects_screen.dart',
    'lib/domain/dna_calculator.dart',
    'assets/images/result_living.jpg',
    'assets/images/result_bedroom.jpg',
    'assets/images/result_kitchen.jpg',
  ];
  final missing = requiredFiles
      .where((path) => !File(path).existsSync())
      .toList();
  final roomAssets = Directory('assets/images')
      .listSync()
      .whereType<File>()
      .where((file) => RegExp(r'room_\d+\.jpg$').hasMatch(file.path))
      .length;
  if (missing.isNotEmpty || roomAssets < 10) {
    stderr.writeln('MVP contract verification failed.');
    if (missing.isNotEmpty) stderr.writeln('Missing: ${missing.join(', ')}');
    if (roomAssets < 10) {
      stderr.writeln('Room catalog has only $roomAssets assets.');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('MVP contract verification passed');
}
