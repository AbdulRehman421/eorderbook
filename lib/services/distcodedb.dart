import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DistcodeDatabaseHelper {
  static Database? _database;
  static const String tableName = 'distributor_table';
  static const String columnId = 'id';
  static const String columnDistCode = 'dist_code';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final String path = join(await getDatabasesPath(), 'distributor_database.db');
    return openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnDistCode TEXT
      )
    ''');
  }

  Future<void> insertDistCode(String distCode) async {
    final Database db = await database;
    await db.delete(tableName);
    await db.insert(tableName, {columnDistCode: distCode});
  }

  Future<List<String>> getDistCodes() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (index) => maps[index][columnDistCode]);
  }
  Future<String?> getDistributorCode() async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query(DistcodeDatabaseHelper.tableName);
    if (result.isNotEmpty) {
      return result.first[DistcodeDatabaseHelper.columnDistCode] as String;
    }
    return null;
  }
}

