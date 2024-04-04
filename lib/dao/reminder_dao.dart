import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/reminder_model.dart';
import '../helpers/database_helper.dart';

class ReminderDAO {
  Future<int> insertReminder(Reminder reminder) async {
    final Database db = await DatabaseHelper.database;
    return await db.insert(
      'reminder',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Reminder>> getRemindersByUserId(int userId) async {
    final Database db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminder',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  Future<int> deleteReminder(int id) async {
    final Database db = await DatabaseHelper.database;
    return await db.delete(
      'reminder',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
