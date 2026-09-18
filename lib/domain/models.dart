enum VoteDecision { like, dislike }

enum ProjectStatus { processing, succeeded, failed }

class RoomReference {
  const RoomReference({
    required this.id,
    required this.title,
    required this.roomType,
    required this.assetPath,
    required this.styles,
    required this.materials,
    required this.palettes,
  });

  final String id;
  final String title;
  final String roomType;
  final String assetPath;
  final List<String> styles;
  final List<String> materials;
  final List<String> palettes;
}

class Affinity {
  const Affinity({
    required this.label,
    required this.score,
    required this.likes,
    required this.dislikes,
  });

  final String label;
  final double score;
  final int likes;
  final int dislikes;
  int get percent => (score * 100).round();

  Map<String, Object> toJson() => {
    'label': label,
    'score': score,
    'likes': likes,
    'dislikes': dislikes,
  };
  factory Affinity.fromJson(Map<String, dynamic> json) => Affinity(
    label: json['label'] as String,
    score: (json['score'] as num).toDouble(),
    likes: json['likes'] as int,
    dislikes: json['dislikes'] as int,
  );
}

class SpaceDna {
  const SpaceDna({
    this.revision = 0,
    this.evaluatedCount = 0,
    this.styles = const [],
    this.materials = const [],
    this.palettes = const [],
  });

  final int revision;
  final int evaluatedCount;
  final List<Affinity> styles;
  final List<Affinity> materials;
  final List<Affinity> palettes;
  bool get isDefined =>
      styles.isNotEmpty || materials.isNotEmpty || palettes.isNotEmpty;

  Map<String, Object> toJson() => {
    'revision': revision,
    'evaluatedCount': evaluatedCount,
    'styles': styles.map((item) => item.toJson()).toList(),
    'materials': materials.map((item) => item.toJson()).toList(),
    'palettes': palettes.map((item) => item.toJson()).toList(),
  };

  factory SpaceDna.fromJson(Map<String, dynamic> json) => SpaceDna(
    revision: json['revision'] as int? ?? 0,
    evaluatedCount: json['evaluatedCount'] as int? ?? 0,
    styles: _affinities(json['styles']),
    materials: _affinities(json['materials']),
    palettes: _affinities(json['palettes']),
  );
}

List<Affinity> _affinities(Object? value) =>
    (value as List<dynamic>? ?? const [])
        .map(
          (item) => Affinity.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

class SpaceProject {
  const SpaceProject({
    required this.id,
    required this.roomType,
    required this.description,
    required this.sourceAssetPath,
    required this.status,
    required this.createdAt,
    this.resultAssetPath,
    this.savedAt,
    this.errorMessage,
  });

  final String id;
  final String roomType;
  final String description;
  final String sourceAssetPath;
  final String? resultAssetPath;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime? savedAt;
  final String? errorMessage;

  SpaceProject copyWith({
    String? resultAssetPath,
    ProjectStatus? status,
    DateTime? savedAt,
    String? errorMessage,
  }) => SpaceProject(
    id: id,
    roomType: roomType,
    description: description,
    sourceAssetPath: sourceAssetPath,
    resultAssetPath: resultAssetPath ?? this.resultAssetPath,
    status: status ?? this.status,
    createdAt: createdAt,
    savedAt: savedAt ?? this.savedAt,
    errorMessage: errorMessage,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'roomType': roomType,
    'description': description,
    'sourceAssetPath': sourceAssetPath,
    'resultAssetPath': resultAssetPath,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'savedAt': savedAt?.toIso8601String(),
    'errorMessage': errorMessage,
  };

  factory SpaceProject.fromJson(Map<String, dynamic> json) => SpaceProject(
    id: json['id'] as String,
    roomType: json['roomType'] as String,
    description: json['description'] as String? ?? '',
    sourceAssetPath: json['sourceAssetPath'] as String,
    resultAssetPath: json['resultAssetPath'] as String?,
    status: ProjectStatus.values.byName(json['status'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    savedAt: json['savedAt'] == null
        ? null
        : DateTime.parse(json['savedAt'] as String),
    errorMessage: json['errorMessage'] as String?,
  );
}

class AppSnapshot {
  const AppSnapshot({
    this.email,
    this.password,
    this.isAuthenticated = false,
    this.votes = const {},
    this.operationIds = const {},
    this.dna = const SpaceDna(),
    this.projects = const [],
    this.projectOperationIds = const {},
  });

  final String? email;
  final String? password;
  final bool isAuthenticated;
  final Map<String, VoteDecision> votes;
  final Set<String> operationIds;
  final SpaceDna dna;
  final List<SpaceProject> projects;
  final Map<String, String> projectOperationIds;

  AppSnapshot copyWith({
    String? email,
    String? password,
    bool? isAuthenticated,
    Map<String, VoteDecision>? votes,
    Set<String>? operationIds,
    SpaceDna? dna,
    List<SpaceProject>? projects,
    Map<String, String>? projectOperationIds,
  }) => AppSnapshot(
    email: email ?? this.email,
    password: password ?? this.password,
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    votes: votes ?? this.votes,
    operationIds: operationIds ?? this.operationIds,
    dna: dna ?? this.dna,
    projects: projects ?? this.projects,
    projectOperationIds: projectOperationIds ?? this.projectOperationIds,
  );

  Map<String, Object?> toJson() => {
    'email': email,
    'password': password,
    'isAuthenticated': isAuthenticated,
    'votes': votes.map((key, value) => MapEntry(key, value.name)),
    'operationIds': operationIds.toList(),
    'dna': dna.toJson(),
    'projects': projects.map((item) => item.toJson()).toList(),
    'projectOperationIds': projectOperationIds,
  };

  factory AppSnapshot.fromJson(Map<String, dynamic> json) => AppSnapshot(
    email: json['email'] as String?,
    password: json['password'] as String?,
    isAuthenticated: json['isAuthenticated'] as bool? ?? false,
    votes: Map<String, dynamic>.from(json['votes'] as Map? ?? const {}).map(
      (key, value) =>
          MapEntry(key, VoteDecision.values.byName(value as String)),
    ),
    operationIds: Set<String>.from(json['operationIds'] as List? ?? const []),
    dna: SpaceDna.fromJson(
      Map<String, dynamic>.from(json['dna'] as Map? ?? const {}),
    ),
    projects: (json['projects'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              SpaceProject.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    projectOperationIds: Map<String, dynamic>.from(
      json['projectOperationIds'] as Map? ?? const {},
    ).map((key, value) => MapEntry(key, value as String)),
  );
}
