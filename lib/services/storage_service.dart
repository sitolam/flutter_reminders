import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder.dart';

class StorageService {
  static const String _key = 'reminders';

  Future<List<Reminder>> loadAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? <String>[];
    return raw.map(Reminder.fromJson).toList();
  }

  Future<void> saveAll(List<Reminder> reminders) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      reminders.map((Reminder r) => r.toJson()).toList(),
    );
  }
}
