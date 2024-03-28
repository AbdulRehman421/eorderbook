// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// // Model class to represent data fetched from API
// class MainCode {
//   final String mainCode;
//
//   MainCode({required this.mainCode});
//
//   factory MainCode.fromJson(Map<String, dynamic> json) {
//     return MainCode(mainCode: json['main_code']);
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'main_code': mainCode,
//     };
//   }
// }
//
// class DatabaseHelper {
//   late Database _database;
//
//   Future<void> initializeDatabase() async {
//     _database = await openDatabase(
//       join(await getDatabasesPath(), 'main_code_database.db'),
//       onCreate: (db, version) {
//         return db.execute(
//           "CREATE TABLE main_codes(id INTEGER PRIMARY KEY, main_code TEXT)",
//         );
//       },
//       version: 1,
//     );
//   }
//
//   Future<void> insertMainCode(MainCode mainCode) async {
//     await _database.insert(
//       'main_codes',
//       mainCode.toJson(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
//
//   Future<MainCode?> getMainCode() async {
//     final List<Map<String, dynamic>> maps = await _database.query('main_codes');
//
//     if (maps.isNotEmpty) {
//       return MainCode.fromJson(maps.first);
//     } else {
//       return null;
//     }
//   }
// }
//
// class MyApp extends StatelessWidget {
//   final DatabaseHelper dbHelper = DatabaseHelper();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Fetch Main Code'),
//         ),
//         body: FetchMainCodeForm(dbHelper: dbHelper),
//       ),
//     );
//   }
// }
//
// class FetchMainCodeForm extends StatefulWidget {
//   final DatabaseHelper dbHelper;
//
//   FetchMainCodeForm({required this.dbHelper});
//
//   @override
//   _FetchMainCodeFormState createState() => _FetchMainCodeFormState();
// }
//
// class _FetchMainCodeFormState extends State<FetchMainCodeForm> {
//   final TextEditingController _distCodeController = TextEditingController();
//   late DatabaseHelper dbHelper;
//   String? _mainCode;
//
//   @override
//   void initState() {
//     super.initState();
//     dbHelper = widget.dbHelper;
//     _initializeDatabase();
//   }
//
//   void _initializeDatabase() async {
//     await dbHelper.initializeDatabase();
//     MainCode? mainCode = await dbHelper.getMainCode();
//     if (mainCode != null) {
//       setState(() {
//         _mainCode = mainCode.mainCode;
//       });
//     }
//   }
//
//   void _fetchMainCode(String distCode) async {
//     final response = await http.get(
//         Uri.parse(
//             'https://seasoftsales.com/eorderbook/get_maincode.php?dist_code=$distCode'));
//
//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//       final mainCode = MainCode.fromJson(jsonData);
//
//       await dbHelper.insertMainCode(mainCode);
//
//       setState(() {
//         _mainCode = mainCode.mainCode;
//       });
//     } else {
//       throw Exception('Failed to load main code');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         children: <Widget>[
//           TextFormField(
//             controller: _distCodeController,
//             decoration: InputDecoration(labelText: 'Enter dist_code'),
//           ),
//           SizedBox(height: 20.0),
//           ElevatedButton(
//             onPressed: () {
//               _fetchMainCode(_distCodeController.text);
//             },
//             child: Text('Fetch Main Code'),
//           ),
//           SizedBox(height: 20.0),
//           if (_mainCode != null)
//             Text(
//               'Main Code: $_mainCode',
//               style: TextStyle(fontSize: 20),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// void main() {
//   runApp(MyApp());
// }
