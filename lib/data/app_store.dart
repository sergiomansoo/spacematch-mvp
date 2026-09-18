import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

abstract interface class AppStore {
  Future<AppSnapshot> read();
  Future<void> write(AppSnapshot snapshot);
  Future<void> clear();
}

class MemoryAppStore implements AppStore {
  AppSnapshot value = const AppSnapshot();

  @override
  Future<AppSnapshot> read() async => AppSnapshot.fromJson(value.toJson());

  @override
  Future<void> write(AppSnapshot snapshot) async {
    value = AppSnapshot.fromJson(snapshot.toJson());
  }

  @override
  Future<void> clear() async {
    value = const AppSnapshot();
  }
}

class PreferencesAppStore implements AppStore {
  static const _key = 'spacematch_snapshot_v1';

  @override
  Future<AppSnapshot> read() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null) return const AppSnapshot();
    try {
      return AppSnapshot.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } on FormatException {
      return const AppSnapshot();
    }
  }

  @override
  Future<void> write(AppSnapshot snapshot) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jsonEncode(snapshot.toJson()));
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
