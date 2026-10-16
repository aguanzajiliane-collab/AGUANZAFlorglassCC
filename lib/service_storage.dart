import 'package:shared_preferences/shared_preferences.dart';

/// Stores a complete snapshot, including an intentionally empty service list.
class ServiceStorage {
  static const key = 'florglassaluminum.services.v1';

  Future<String?> read() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    return preferences.getString(key);
  }

  Future<void> write(String snapshot) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(key, snapshot)) {
      throw StateError('Local storage rejected the service update.');
    }
  }
}
