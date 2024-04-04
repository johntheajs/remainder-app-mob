import 'package:sqflite/sqflite.dart';
import 'package:reminder_app_mob/models/user_model.dart';
import 'package:reminder_app_mob/helpers/database_helper.dart';

class UserDao {
  final Future<Database> _database = DatabaseHelper.database;

  Future<int> insertUser(User user) async {
    final db = await _database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User(
        id: maps[0]['id'],
        username: maps[0]['username'],
        password: maps[0]['password'],
      );
    }

    return null;
  }
}
