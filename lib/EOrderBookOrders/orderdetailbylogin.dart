import 'dart:convert';
import 'dart:io';
import 'package:eorderbook/EOrderBookOrders/ordermaps.dart';
import 'package:eorderbook/EOrderBookOrders/ordermapsbylogin.dart';
import 'package:eorderbook/models/user.dart';
import 'package:eorderbook/screens/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as paths;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../services/distcodedb.dart';

class OrderDetailsLogin extends StatefulWidget {

  const OrderDetailsLogin({super.key});

  @override
  State<OrderDetailsLogin> createState() => _OrderDetailsLoginState();
}

class _OrderDetailsLoginState extends State<OrderDetailsLogin> {
  DateTime? selectedDate;

  void dispose(){
    super.dispose();
  }
  Future<bool> showLogoutDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout Confirmation"),
          content: const Text("Are you sure to logout from this account?"),
          actions: <Widget>[
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("YES"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshData() async {
    try {
      await syncUsers();
      await fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data refreshed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh data: $e')),
      );
    }
  }
  String dist_Code = '0';
  Future<void> _getDistCode() async {
    String? distributorCode = await DistcodeDatabaseHelper().getDistributorCode();
    setState(() {
      dist_Code = distributorCode ?? '';
    });
  }
  final String apiUrl =
      "https://seasoftsales.com/eorderbook/get_users.php";
  late Database database;
  List<User> users = [];
  User? selectedUser;
  Future<void> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = paths.join(directory.path, "users.db");
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE users(user_id INTEGER PRIMARY KEY, role_id INTEGER, dist_code INTEGER, username TEXT, description TEXT, mobile TEXT, email TEXT, password TEXT, eorderbookuser INTEGER, active INTEGER)");
        });
    await clearUsers(); // Clear existing users from local database
    await syncUsers(); // Sync users from API when the app starts
    await fetchUsers(); // Fetch users from the local database
  }

  Future<void> clearUsers() async {
    await database.delete('users');
  }

  Future<void> syncUsers() async {
    try {
      List<User> fetchedUsers = await getUsers(dist_Code);
      await database.transaction((txn) async {
        for (var user in fetchedUsers) {
          await txn.insert('users', user.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
      print("Users synced successfully!");
    } catch (e) {
      print("Error syncing users: $e");
    }
  }

  Future<List<User>> getUsers(String distCode) async {
    final Map<String, String> requestData = {'dist_code': distCode};
    final String requestBody = json.encode(requestData);

    final response = await http.post(
      Uri.parse('https://seasoftsales.com/eorderbook/get_users.php/$distCode'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
  void initState() {
    super.initState();
    _getDistCode();
    _refreshData();
    showInputDialog();
    initializeDatabase();
    selectedDate = DateTime.now();
  }

  Future<void> fetchUsers() async {
    List<Map<String, dynamic>> userMaps = await database.query('users');
    List<User> userList = userMaps.map((userMap) => User.fromMap(userMap)).toList();

    // Filter users based on the eorderbook field
    List<User> filteredUsers = userList.where((user) => user.eOrderBookUser == 1 || user.eOrderBookUser == 2).toList();

    setState(() {
      users = filteredUsers;
    });
  }
  Future<void> showInputDialog() async {
    selectedDate = DateTime.now();
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Dist Code : $dist_Code", style: TextStyle(fontSize: 18)),
                  DropdownButton<User>(
                    hint: Text('Select User'),
                    value: selectedUser,
                    onChanged: (User? newValue) {
                      setState(() {
                        selectedUser = newValue;
                      });
                    },
                    items: users.map<DropdownMenuItem<User>>((User user) {
                      return DropdownMenuItem<User>(
                        value: user,
                        child: Text(user.username),
                      );
                    }).toList(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        // Save selected date to SharedPreferences
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setInt('selectedDate', pickedDate.millisecondsSinceEpoch);
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text('Select Date'),
                  ),
                  if (selectedDate != null)
                    Text(
                      'Selected Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await fetchData(
                      dist_Code,
                     selectedUser!.username,
                      selectedDate,
                      // orderData,
                    );
                    // Clear selected date
                    selectedDate = null;
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> fetchData(
      String distCode, String userName, DateTime? selectedDate) async {
    setState(() {
      isLoading = true;
    });
    if (selectedDate == null) {
      // Show a toast if no date is selected
      Fluttertoast.showToast(
        msg: 'Please select a date.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    String formattedDate =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    String apiUrl =
        'https://seasoftsales.com/eorderbook/get_orders.php?dist_code=$distCode&user_name=$userName&selected_date=$formattedDate';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Clear existing data before adding new data
      setState(() {
        orderData.clear();

        for (var item in data) {
          // Add data to the orderData list
          orderData.add(item);
        }
      });
    } else {
      // Show a toast for the error
      Fluttertoast.showToast(
        msg: 'Failed to load data. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    setState(() {
      isLoading = false;
    });
  }
  List<dynamic> orderData = [];


  bool isLoading = false;
  double calculateTotalOrderAmount() {
    double totalAmount = 0.0;

    for (var item in orderData) {
      totalAmount += double.parse(item['order_amount']);
    }

    return totalAmount;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              bool confirmDelete = await showLogoutDialog(context);
              if (confirmDelete) {
                SharedPreferences s = await SharedPreferences.getInstance();
                s.clear();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                        (route) => false);
              } else {
                // Cancel delete action
              }
            },
            icon: const Icon(
              Icons.logout,
            )),

        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text('Order Details'),
        actions: [
          IconButton(onPressed: () {
            _getDistCode();
            showInputDialog();
          }, icon: Icon(Icons.calendar_month))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isLoading && orderData.isNotEmpty)
          Center(child: Text('Order Amount : ${calculateTotalOrderAmount().toStringAsFixed(2)}',style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
          ),)),
          SizedBox(
            height: 10,
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (!isLoading && orderData.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: orderData.length,
                itemBuilder: (context, index) {
                  orderData.sort((a, b) => a['date'].compareTo(b['date']));
                  var item = orderData[index];
                  return Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Text('${index + 1}',style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'],style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                            Text('${item['areaname']}  (${item['order_amount']})'),
                          ],
                        )
                      ],
                    ),
                    // child: ListTile(
                    //
                    //   leading: Text('${index + 1}',style: TextStyle(
                    //     fontSize: 20,
                    //     fontWeight: FontWeight.bold
                    //   ),),
                    //   title: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(item['name'],style: TextStyle(
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold
                    //       ),),
                    //     ],
                    //   ),
                    //   subtitle: Text('${item['areaname']}  (${item['order_amount']})'),
                    //
                    //   onTap: () {
                    //     // Handle onTap if needed
                    //   },
                    // ),
                  );
                },
              ),
            ),
          if(!isLoading && orderData.isEmpty)
            Center(heightFactor: 2,
              child:
                  Lottie.asset(kIsWeb
                      ? 'not_found_data.json'
                      : 'assets/not_found_data.json'),
            ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: orderData.isNotEmpty,
        child: FloatingActionButton.extended(onPressed: () async {

          Navigator.push(context, MaterialPageRoute(builder: (context) => OrderMapLogin(distcode: dist_Code, username: selectedUser!.username,),));
        },
          label: Text('Map View'),
        ),
      ),
    );
  }
}
