import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/maincode.dart';

class MainCodeDatabaseHelper {
  late Database _database;

  Future<void> initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'main_code_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE main_codes(id INTEGER PRIMARY KEY, main_code TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertMainCode(MainCode mainCode) async {
    if (_database == null) {
      throw Exception("Database not initialized");
    }

    await _database.insert(
      'main_codes',
      mainCode.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MainCode?> getMainCode() async {
    if (_database == null) {
      throw Exception("Database not initialized");
    }

    final List<Map<String, dynamic>> maps = await _database.query('main_codes');

    if (maps.isNotEmpty) {
      return MainCode.fromJson(maps.first);
    } else {
      return null;
    }
  }
}
