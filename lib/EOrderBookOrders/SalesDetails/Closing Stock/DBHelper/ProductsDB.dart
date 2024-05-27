import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/Model/ProductsModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelperProduct {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'products.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('''
          CREATE TABLE products(
            minorder TEXT,
            companycode TEXT,
            unit TEXT,
            name TEXT,
            pcode TEXT PRIMARY KEY,
            rate TEXT,
            qty TEXT,
            pbal TEXT,
            'order' TEXT,
            dip TEXT,
            cname TEXT
          )
          ''');
    });
  }

  Future<void> insertProduct(Product product) async {
    final Database db = await database;
    await db.insert('products', product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearProducts() async {
    final db = await database;
    await db.delete('products');
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: "pcode = ?",
      whereArgs: [product.pCode],
    );
  }

  Future<List<Product>> getProducts() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product(
        minOrder: maps[i]['minorder'],
        companyCode: maps[i]['companycode'],
        unit: maps[i]['unit'],
        name: maps[i]['name'],
        pCode: maps[i]['pcode'],
        rate: maps[i]['rate'],
        qty: maps[i]['qty'],
        pBal: maps[i]['pbal'],
        order: maps[i]['order'],
        dip: maps[i]['dip'],
        cname: maps[i]['cname'],
      );
    });
  }
}
