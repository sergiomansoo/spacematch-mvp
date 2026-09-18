import 'package:flutter/foundation.dart';

import '../data/app_store.dart';
import '../data/generation_service.dart';
import '../domain/dna_calculator.dart';
import '../domain/models.dart';

class AppController extends ChangeNotifier {
  AppController({required this._store, required this._generator});

  final AppStore _store;
  final GenerationService _generator;
  final _calculator = const DnaCalculator();
  AppSnapshot _snapshot = const AppSnapshot();
  bool isBusy = false;
  String? errorMessage;

  bool get isAuthenticated => _snapshot.isAuthenticated;
  String? get email => _snapshot.email;
  Map<String, VoteDecision> get votes => Map.unmodifiable(_snapshot.votes);
  SpaceDna get dna => _snapshot.dna;
  List<SpaceProject> get projects =>
      List.unmodifiable(_snapshot.projects.reversed);

  final List<RoomReference> rooms = const [
    RoomReference(
      id: 'r1',
      title: 'Sala serena',
      roomType: 'Sala',
      assetPath: 'assets/images/room_01.jpg',
      styles: ['Minimalista', 'Contemporâneo'],
      materials: ['Madeira', 'Linho'],
      palettes: ['Areia', 'Neutros'],
    ),
    RoomReference(
      id: 'r2',
      title: 'Sala natural',
      roomType: 'Sala',
      assetPath: 'assets/images/room_02.jpg',
      styles: ['Minimalista', 'Escandinavo'],
      materials: ['Madeira', 'Linho'],
      palettes: ['Areia', 'Neutros'],
    ),
    RoomReference(
      id: 'r3',
      title: 'Cozinha leve',
      roomType: 'Cozinha',
      assetPath: 'assets/images/room_03.jpg',
      styles: ['Minimalista', 'Contemporâneo'],
      materials: ['Madeira', 'Pedra'],
      palettes: ['Areia', 'Branco'],
    ),
    RoomReference(
      id: 'r4',
      title: 'Quarto acolhedor',
      roomType: 'Quarto',
      assetPath: 'assets/images/room_04.jpg',
      styles: ['Escandinavo', 'Minimalista'],
      materials: ['Madeira', 'Linho'],
      palettes: ['Neutros', 'Branco'],
    ),
    RoomReference(
      id: 'r5',
      title: 'Sala urbana',
      roomType: 'Sala',
      assetPath: 'assets/images/room_05.jpg',
      styles: ['Industrial', 'Contemporâneo'],
      materials: ['Metal', 'Concreto'],
      palettes: ['Cinza', 'Terrosos'],
    ),
    RoomReference(
      id: 'r6',
      title: 'Cozinha contemporânea',
      roomType: 'Cozinha',
      assetPath: 'assets/images/room_06.jpg',
      styles: ['Contemporâneo', 'Minimalista'],
      materials: ['Pedra', 'Madeira'],
      palettes: ['Areia', 'Branco'],
    ),
    RoomReference(
      id: 'r7',
      title: 'Quarto essencial',
      roomType: 'Quarto',
      assetPath: 'assets/images/room_07.jpg',
      styles: ['Minimalista', 'Escandinavo'],
      materials: ['Linho', 'Madeira'],
      palettes: ['Neutros', 'Areia'],
    ),
    RoomReference(
      id: 'r8',
      title: 'Loft marcante',
      roomType: 'Sala',
      assetPath: 'assets/images/room_08.jpg',
      styles: ['Industrial', 'Contemporâneo'],
      materials: ['Metal', 'Concreto'],
      palettes: ['Cinza', 'Terrosos'],
    ),
    RoomReference(
      id: 'r9',
      title: 'Sala orgânica',
      roomType: 'Sala',
      assetPath: 'assets/images/room_09.jpg',
      styles: ['Orgânico', 'Contemporâneo'],
      materials: ['Madeira', 'Pedra'],
      palettes: ['Terrosos', 'Areia'],
    ),
    RoomReference(
      id: 'r10',
      title: 'Quarto calmo',
      roomType: 'Quarto',
      assetPath: 'assets/images/room_10.jpg',
      styles: ['Minimalista', 'Orgânico'],
      materials: ['Linho', 'Madeira'],
      palettes: ['Areia', 'Branco'],
    ),
    RoomReference(
      id: 'r11',
      title: 'Cozinha precisa',
      roomType: 'Cozinha',
      assetPath: 'assets/images/room_11.jpg',
      styles: ['Contemporâneo', 'Industrial'],
      materials: ['Pedra', 'Metal'],
      palettes: ['Cinza', 'Branco'],
    ),
    RoomReference(
      id: 'r12',
      title: 'Sala luminosa',
      roomType: 'Sala',
      assetPath: 'assets/images/room_12.jpg',
      styles: ['Escandinavo', 'Minimalista'],
      materials: ['Madeira', 'Linho'],
      palettes: ['Branco', 'Neutros'],
    ),
    RoomReference(
      id: 'r13',
      title: 'Refúgio natural',
      roomType: 'Quarto',
      assetPath: 'assets/images/room_13.jpg',
      styles: ['Orgânico', 'Escandinavo'],
      materials: ['Madeira', 'Linho'],
      palettes: ['Terrosos', 'Neutros'],
    ),
    RoomReference(
      id: 'r14',
      title: 'Cozinha essencial',
      roomType: 'Cozinha',
      assetPath: 'assets/images/room_14.jpg',
      styles: ['Minimalista', 'Contemporâneo'],
      materials: ['Pedra', 'Madeira'],
      palettes: ['Areia', 'Branco'],
    ),
    RoomReference(
      id: 'r15',
      title: 'Sala de contraste',
      roomType: 'Sala',
      assetPath: 'assets/images/room_15.jpg',
      styles: ['Industrial', 'Orgânico'],
      materials: ['Concreto', 'Madeira'],
      palettes: ['Cinza', 'Terrosos'],
    ),
  ];

  Future<void> initialize() async {
    _snapshot = await _store.read();
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    _validateCredentials(email, password);
    _snapshot = _snapshot.copyWith(
      email: email.trim().toLowerCase(),
      password: password,
      isAuthenticated: true,
    );
    await _persist();
  }

  Future<void> login({required String email, required String password}) async {
    _validateCredentials(email, password);
    if (_snapshot.email == null) {
      throw const AuthException('Crie sua conta antes de entrar.');
    }
    if (_snapshot.email != email.trim().toLowerCase() ||
        _snapshot.password != password) {
      throw const AuthException('E-mail ou senha incorretos.');
    }
    _snapshot = _snapshot.copyWith(isAuthenticated: true);
    await _persist();
  }

  Future<void> recover(String email) async {
    if (!email.contains('@')) {
      throw const AuthException('Informe um e-mail válido.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<void> logout() async {
    _snapshot = _snapshot.copyWith(isAuthenticated: false);
    await _persist();
  }

  Future<void> deleteAccount() async {
    await _store.clear();
    _snapshot = const AppSnapshot();
    notifyListeners();
  }

  Future<void> vote({
    required String roomId,
    required VoteDecision decision,
    required String operationId,
  }) async {
    if (_snapshot.operationIds.contains(operationId)) return;
    final nextVotes = Map<String, VoteDecision>.from(_snapshot.votes)
      ..[roomId] = decision;
    final nextOps = Set<String>.from(_snapshot.operationIds)..add(operationId);
    final nextDna = _calculator.calculate(
      rooms: rooms,
      votes: nextVotes,
      revision: _snapshot.dna.revision + 1,
    );
    _snapshot = _snapshot.copyWith(
      votes: nextVotes,
      operationIds: nextOps,
      dna: nextDna,
    );
    await _persist();
  }

  Future<SpaceProject> createProject({
    required String sourcePath,
    required String roomType,
    required String description,
    required String operationId,
  }) async {
    final existingId = _snapshot.projectOperationIds[operationId];
    if (existingId != null) {
      return _snapshot.projects.firstWhere((item) => item.id == existingId);
    }
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    final id = 'p${DateTime.now().microsecondsSinceEpoch}';
    var project = SpaceProject(
      id: id,
      roomType: roomType,
      description: description.trim(),
      sourceAssetPath: sourcePath,
      status: ProjectStatus.processing,
      createdAt: DateTime.now().toUtc(),
    );
    final projects = List<SpaceProject>.from(_snapshot.projects)..add(project);
    final operations = Map<String, String>.from(_snapshot.projectOperationIds)
      ..[operationId] = id;
    _snapshot = _snapshot.copyWith(
      projects: projects,
      projectOperationIds: operations,
    );
    await _persist(notify: false);
    try {
      final result = await _generator.generate(project);
      project = project.copyWith(
        status: ProjectStatus.succeeded,
        resultAssetPath: result,
      );
    } catch (error) {
      project = project.copyWith(
        status: ProjectStatus.failed,
        errorMessage: 'Não foi possível gerar esta proposta.',
      );
      errorMessage = project.errorMessage;
    }
    _replaceProject(project);
    isBusy = false;
    await _persist();
    return project;
  }

  Future<void> saveProject(String id) async {
    final project = _snapshot.projects.firstWhere((item) => item.id == id);
    _replaceProject(
      project.copyWith(savedAt: project.savedAt ?? DateTime.now().toUtc()),
    );
    await _persist();
  }

  Future<SpaceProject> retryProject(String id) async {
    var project = projectById(id);
    if (project.status != ProjectStatus.failed || isBusy) return project;
    isBusy = true;
    errorMessage = null;
    project = project.copyWith(status: ProjectStatus.processing);
    _replaceProject(project);
    await _persist();
    try {
      final result = await _generator.generate(project);
      project = project.copyWith(
        status: ProjectStatus.succeeded,
        resultAssetPath: result,
      );
    } catch (_) {
      project = project.copyWith(
        status: ProjectStatus.failed,
        errorMessage: 'Não foi possível gerar esta proposta.',
      );
      errorMessage = project.errorMessage;
    }
    _replaceProject(project);
    isBusy = false;
    await _persist();
    return project;
  }

  SpaceProject projectById(String id) =>
      _snapshot.projects.firstWhere((item) => item.id == id);

  RoomReference? get nextRoom {
    for (final room in rooms) {
      if (!_snapshot.votes.containsKey(room.id)) return room;
    }
    return null;
  }

  void _replaceProject(SpaceProject project) {
    final projects = _snapshot.projects
        .map((item) => item.id == project.id ? project : item)
        .toList();
    _snapshot = _snapshot.copyWith(projects: projects);
  }

  Future<void> _persist({bool notify = true}) async {
    await _store.write(_snapshot);
    if (notify) notifyListeners();
  }

  void _validateCredentials(String email, String password) {
    if (!email.contains('@')) {
      throw const AuthException('Informe um e-mail válido.');
    }
    if (password.length < 6) {
      throw const AuthException('A senha deve ter ao menos 6 caracteres.');
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
