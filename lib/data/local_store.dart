import 'package:shared_preferences/shared_preferences.dart';

/// Small key-value storage on the device. Values are plain strings (JSON).
abstract class LocalStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

/// Real storage that survives app restarts.
class SharedPreferencesStore implements LocalStore {
  SharedPreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPreferencesStore> open() async =>
      SharedPreferencesStore(await SharedPreferences.getInstance());

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// For tests. Pass the same [data] map to a second instance to simulate
/// closing and reopening the app.
class InMemoryLocalStore implements LocalStore {
  InMemoryLocalStore([Map<String, String>? data]) : data = data ?? {};

  final Map<String, String> data;

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> remove(String key) async => data.remove(key);
}
