import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/Model/OrderModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelperOrder {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'orders.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('''
          CREATE TABLE orders(
            name TEXT,
            companycode TEXT,
            companyname TEXT,
            cdist_code TEXT,
            cdist_name TEXT PRIMARY KEY,
            pur_no TEXT,
            pcode TEXT,
            dpur_no TEXT,
            rate TEXT,
            qty TEXT,
            bonus TEXT,
            dip TEXT,
            date TEXT,
            dist_code TEXT,
            order_value TEXT
          )
          ''');
    });
  }

  Future<void> insertOrders(Order order) async {
    final Database db = await database;
    try {
      await db.insert(
        'orders',
        order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting order: $e');
    }
  }


  Future<void> clearOrders() async {
    final db = await database;
    await db.delete('orders');
  }



  Future<List<Order>> getOrders() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('orders');
    return List.generate(maps.length, (i) {
      return Order(
        name: maps[i]['name'],
        companyCode: maps[i]['companycode'],
        companyName: maps[i]['companyname'],
        distributorCode: maps[i]['cdist_code'],
        distributorName: maps[i]['cdist_name'],
        purchaseNumber: maps[i]['pur_no'],
        productCode: maps[i]['pcode'],
        purchaseOrderNumber: maps[i]['dpur_no'],
        rate: double.parse(maps[i]['rate']),
        quantity: int.parse(maps[i]['qty']),
        bonus: int.parse(maps[i]['bonus']),
        discount: double.parse(maps[i]['dip']),
        date: DateTime.parse(maps[i]['date']),
        distcode: maps[i]['dist_code'],
        orderValue: double.parse(maps[i]['order_value']),
      );
    });
  }
}
