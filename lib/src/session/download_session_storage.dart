import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/download_session.dart';

class DownloadSessionStorage {
  const DownloadSessionStorage();

  static const String _sessionKey =
      'flutter_apk_updater.download_session';

  Future<void> save(
    DownloadSession session,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      _sessionKey,
      jsonEncode(
        session.toJson(),
      ),
    );
  }

  Future<DownloadSession?> load() async {
    final preferences =
        await SharedPreferences.getInstance();

    final json = preferences.getString(
      _sessionKey,
    );

    if (json == null) {
      return null;
    }

    return DownloadSession.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  Future<void> clear() async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(
      _sessionKey,
    );
  }

  Future<bool> exists() async {
    final preferences =
        await SharedPreferences.getInstance();

    return preferences.containsKey(
      _sessionKey,
    );
  }
}