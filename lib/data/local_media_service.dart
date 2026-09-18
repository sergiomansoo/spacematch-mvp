import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalMediaService {
  const LocalMediaService();

  Future<String> persist(String temporaryPath) async {
    if (temporaryPath.startsWith('assets/')) return temporaryPath;
    final directory = await getApplicationDocumentsDirectory();
    final extension = temporaryPath.contains('.')
        ? temporaryPath.substring(temporaryPath.lastIndexOf('.'))
        : '.jpg';
    final target = File(
      '${directory.path}${Platform.pathSeparator}spacematch_${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    return (await File(temporaryPath).copy(target.path)).path;
  }
}
