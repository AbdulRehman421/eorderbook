import 'dart:async';
import 'dart:convert';
import 'package:eorderbook/models/account.dart';
import 'package:eorderbook/models/area.dart';
import 'package:eorderbook/models/company.dart';
import 'package:eorderbook/models/order_details.dart';
import 'package:eorderbook/models/product.dart';
import 'package:eorderbook/models/sector.dart';
import 'package:eorderbook/models/user.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'eOrderBook.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> deleteAllData() async {
    // Get a reference to the database
    Database database = await instance.database;

    // List of tables to truncate
    final tables = [
      'account',
      'area',
      'company',
      'distributor',
      'eorderbook',
      'eorderbook_master',
      'product',
      'sector',
      'user',
    ];

    for (final table in tables) {
      await database.delete(table);
    }

    // Close the database
    await database.close();
  }

  Future<void> _createTables(Database db, int version) async {
    // Create account table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS account (
        ID INTEGER PRIMARY KEY,
        dist_code INTEGER NOT NULL,
        code INTEGER NOT NULL,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        areacd INTEGER NOT NULL,
        lic_exp_date TEXT NOT NULL,
        active TEXT NOT NULL DEFAULT 'Y'
      )
    ''');

    // Create area table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS area (
        ID INTEGER PRIMARY KEY,
        dist_code INTEGER NOT NULL,
        areacd INTEGER NOT NULL,
        name TEXT NOT NULL,
        seccd INTEGER NOT NULL
      )
    ''');

    // Create company table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS company (
        ID INTEGER PRIMARY KEY,
        dist_code INTEGER NOT NULL,
        cmpcd TEXT NOT NULL,
        name TEXT NOT NULL
      )
    ''');

    // Create distributor table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS distributor (
        ID INTEGER PRIMARY KEY,
        dist_code INTEGER NOT NULL,
        main_code INTEGER NOT NULL,
        name TEXT NOT NULL,
        bonus INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create eorderbook table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS eorderbook (
        id INTEGER PRIMARY KEY,
        order_id INTEGER NOT NULL,
        pcode TEXT NOT NULL,
        qty INTEGER NOT NULL,
        bonus INTEGER NOT NULL,
        rate REAL NOT NULL,
        discount REAL NOT NULL
      )
    ''');

    // Create eorderbook_master table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS eorderbook_master (
        order_id INTEGER PRIMARY KEY,
        user_name TEXT NOT NULL,
        dist_code INTEGER NOT NULL,
        app_orderno INTEGER NOT NULL,
        code INTEGER NOT NULL,
        date TEXT NOT NULL,
        order_amount REAL NOT NULL,
        latitude TEXT NOT NULL,
        longitude TEXT NOT NULL,
        remarks TEXT NOT NULL
      )
    ''');

    // Create product table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS product (
        ID INTEGER PRIMARY KEY,
        dist_code INTEGER NOT NULL,
        pcode TEXT NOT NULL,
        cmpcd TEXT NOT NULL,
        name TEXT NOT NULL,
        tp REAL NOT NULL,
        rp REAL NOT NULL,
        balance INTEGER NOT NULL,
        grcd TEXT NOT NULL,
        active TEXT NOT NULL DEFAULT 'Y'
      )
    ''');

    // Create sector table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sector (
        ID INTEGER PRIMARY KEY,
        dist_code INTEGER NOT NULL,
        seccd INTEGER NOT NULL,
        name TEXT NOT NULL
      )
    ''');

    // Create user table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user (
        user_id INTEGER PRIMARY KEY,
        role_id INTEGER NOT NULL,
        dist_code INTEGER NOT NULL,
        username TEXT NOT NULL,
        description TEXT NOT NULL,
        mobile TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        eorderbookuser INTEGER NOT NULL DEFAULT 0,
        active INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
  Future<void> truncateAllTables() async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    // List of tables to truncate
    final tables = ['account', 'area', 'company', 'product', 'sector', 'user'];

    for (final table in tables) {
      await db.delete(table);
    }

    await db.close();
  }

  Future<List<User>> getAllUsers() async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    final List<Map<String, dynamic>> maps = await db.query('user');

    await db.close();

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<int> getAllOrdersCount() async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    // Retrieve all orders count from eorderbook_master table
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM eorderbook_master'));

    // Close the database
    await db.close();

    return count ?? 0;
  }

  Future<List<Map<String, dynamic>>> getOrdersFromDatabase({List<int>? selectedOrderIds}) async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(join(databasePath, 'eOrderBook.db'));

    if (selectedOrderIds != null && selectedOrderIds.isNotEmpty) {
      // Retrieve selected orders from eorderbook_master table
      final selectedOrdersList = await database.query(
        'eorderbook_master',
        where: 'order_id IN (${selectedOrderIds.map((id) => '?').join(', ')})',
        whereArgs: selectedOrderIds,
      );

      // Close the database
      await database.close();

      return selectedOrdersList;
    } else {
      // Retrieve all orders from eorderbook_master table
      final orderDetailsList = await database.query('eorderbook_master');

      // Close the database
      await database.close();

      return orderDetailsList;
    }
  }
  Future<List<Map<String, dynamic>>> getProductDetailsForOrder(orderId) async {
    // Open the database
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(join(databasePath, 'eOrderBook.db'));

    // Query product details for a specific order from eorderbook table
    final productDetailsList =
    await database.query('eorderbook', where: 'order_id = ?', whereArgs: [orderId]);

    // Close the database
    await database.close();

    return productDetailsList;
  }


   Future<String> getAllOrdersAsJson() async {
    // Retrieve order details from the database
    final orderDetailsList = await getOrdersFromDatabase();
    debugPrint("Order Details: $orderDetailsList");

    // Create a list to hold the final order data
    final List<Map<String, dynamic>> orders = [];

    for (final orderDetails in orderDetailsList) {
      // Convert order details to OrderDetails object
      final order = OrderDetails.fromMap(orderDetails);

      debugPrint("Order Details: $order");

      // Retrieve product details for the current order
      final productDetailsList = await getProductDetailsForOrder(order.orderId);
      debugPrint("Product Details: $productDetailsList");


      // Convert product details to ProductDetails objects
      final products = productDetailsList.map((productDetails) {
        return ProductDetails.fromMap(productDetails);
      }).toList();

      // Create the final order map
      final orderMap = {
        'orderDetails': order.toMap(),
        'productDetails': products.map((product) => product.toMap()).toList(),
      };

      // Add the order map to the orders list
      orders.add(orderMap);
    }

    // Convert the orders list to JSON
    final jsonOrders = jsonEncode({'orders': orders});

    return jsonOrders;
  }

  Future<String> getSelectedOrdersAsJson(List<int> selectedOrderIds) async {
    // Retrieve selected order details from the database
    final selectedOrderDetailsList = await getOrdersFromDatabase(selectedOrderIds: selectedOrderIds);

    // Create a list to hold the final order data
    final List<Map<String, dynamic>> orders = [];

    for (final orderDetails in selectedOrderDetailsList) {
      // Convert order details to OrderDetails object
      final order = OrderDetails.fromMap(orderDetails);

      // Retrieve product details for the current order
      final productDetailsList = await getProductDetailsForOrder(order.orderId);

      // Convert product details to ProductDetails objects
      final products = productDetailsList.map((productDetails) {
        return ProductDetails.fromMap(productDetails);
      }).toList();

      // Create the final order map
      final orderMap = {
        'orderDetails': order.toMap(),
        'productDetails': products.map((product) => product.toMap()).toList(),
      };

      // Add the order map to the orders list
      orders.add(orderMap);
    }

    // Convert the orders list to JSON
    final jsonOrders = jsonEncode({'orders': orders});

    return jsonOrders;
  }

  Future<void> bulkInsertAccounts(List<Account> accounts) async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    final batch = db.batch();

    for (final account in accounts) {
      batch.insert('account', account.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();

    // Close the database
    await db.close();
  }

  Future<void> bulkInsertAreas(List<Area> areas) async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    final batch = db.batch();

    for (final area in areas) {
      batch.insert('area', area.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();

    // Close the database
    await db.close();
  }

  Future<void> bulkInsertCompanies(List<Company> companies) async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    final batch = db.batch();

    for (final company in companies) {
      batch.insert('company', company.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();

    // Close the database
    await db.close();
  }


  Future<void> bulkInsertProducts(List<Product> products) async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    final batch = db.batch();

    try {
      for (final product in products) {
        batch.insert('product', product.toSqlMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error inserting products: $e');
    }

    // Close the database
    await db.close();
  }


  Future<void> bulkInsertSectors(List<Sector> sectors) async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    final batch = db.batch();

    try {
      for (final sector in sectors) {
        batch.insert('sector', sector.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error inserting sectors: $e');
    }

    // Close the database
    await db.close();
  }

  Future<void> bulkInsertUsers(List<User> users) async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    final batch = db.batch();

    try {
      for (final user in users) {
        batch.insert('user', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error inserting users: $e');
    }

    // Close the database
    await db.close();
  }

  insertOrder(orderDetails, List<Product> productDetails) async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    // Insert order details into eorderbook_master table
    int orderMasterId = await db.insert('eorderbook_master', orderDetails,
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Insert product details into eorderbook table
    for (var element in productDetails) {
      await db.insert(
      'eorderbook',
          {
            'pcode': element.pCode,
            'order_id': orderMasterId,
            'qty': element.quantity,
            'bonus': element.bonus,
            'discount': element.discount,
            'rate': element.tp
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Close the database
    await db.close();
  }
  insertOrders(orderDetails, List<Product> productDetails) async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    // Insert order details into eorderbook_master table
    int orderMasterId = await db.insert('eorderbook_master', orderDetails,
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Insert product details into eorderbook table
    for (var element in productDetails) {
      await db.insert(
      'eorderbook',
          {
            'pcode': element.pCode,
            'order_id': orderMasterId,
            'qty': element.quantity,
            'bonus': element.bonus,
            'discount': element.discount,
            'rate': element.tp
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Close the database
    await db.close();
  }

  updateInvoice(orderId, List<Product> products) async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }

    await db.delete(
      'eorderbook',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    for (Product item in products) {
      await db.insert('eorderbook', {
        'pcode': item.pCode,
        'order_id': orderId,
        'qty': item.quantity,
        'bonus': item.bonus,
        'discount': item.discount,
        'rate': item.tp
      });
    }

    // Close the database
    await db.close();
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    Database db = await database;

    if(!db.isOpen) {
      String path = join(await getDatabasesPath(), 'eOrderBook.db');
      db = await openDatabase(path);
    }


    // Query the user table for the given dist_code, username, and password
    List<Map<String, dynamic>> results = await db.query(
      'user',
      where: 'username = ? AND password = ?',
      // where: 'username = ? AND password = ? AND eorderbookuser = 1',
      whereArgs: [username, password],
    );

    close();

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null; // User not found or incorrect username/password combination
    }
  }

  Future<void> close() async => _database?.close();
}
