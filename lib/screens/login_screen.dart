import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eorderbook/EOrderBookOrders/OrderLoginHome.dart';
import 'package:eorderbook/screens/invoice_list_screen.dart';
import 'package:eorderbook/services/api_service.dart';
import 'package:eorderbook/services/db_helper.dart';
import 'package:eorderbook/services/distcodedb.dart';
import 'package:eorderbook/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eorderbook/models/maincode.dart';
import 'package:eorderbook/services/maincodedb.dart';
import 'package:http/http.dart' as http;

import '../EOrderBookOrders/OrderDetailLogin/orderdetailbylogin.dart';
import '../EOrderBookOrders/SalesDetails/SalesDetails.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String distCode = "";
  bool _isPasswordVisible = false;
  @override
  void initState() {
    super.initState();
    _loadDistributors();
    _getDistCode();
    _initializeDatabase();
  }
  String? _mainCode;
  MainCodeDatabaseHelper dbHelper = MainCodeDatabaseHelper();

  void _initializeDatabase() async {
    await dbHelper.initializeDatabase();
    MainCode? mainCode = await dbHelper.getMainCode();
    if (mainCode != null) {
      setState(() {
        _mainCode = mainCode.mainCode;
      });
    }
  }

  void _fetchMainCode(String distCode) async {
    final response = await http.get(
        Uri.parse(
            'https://seasoftsales.com/eorderbook/get_maincode.php?dist_code=$distCode'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final mainCode = MainCode.fromJson(jsonData);

      await dbHelper.insertMainCode(mainCode);

      setState(() {
        _mainCode = mainCode.mainCode;
      });
    } else {
      throw Exception('Failed to load main code');
    }
  }
  _loadDistributors() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        Utils.showToast('No internet connection');
        return false;
      }



    } catch (e) {
      debugPrint('Error loading distributors: $e');
      return false;
    }
    return true;
  }

  String dist_Code = '0';
  Future<void> _getDistCode() async {
    String? distributorCode = await DistcodeDatabaseHelper().getDistributorCode();
    setState(() {
      dist_Code = distributorCode ?? '0';
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              // ApiService apiService = ApiService();
              // List<Distributor> distributorsFromApi =
              // await apiService.getDistributors();
              // print('helo $distributorsFromApi');
              await Utils.showLoaderDialog(context ,"Checking Orders", "Please wait..." );
              var ordersCount = await DatabaseHelper.instance.getAllOrdersCount();
              Navigator.of(context).pop();
              if (ordersCount < 1) {

                await _showDistributorDialog();
              }
              else {
                Utils.showToast("Please delete or send all orders");
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _getDistCode();
                });
              },
              child: Text(
                'Welcome Back $dist_Code',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              textInputAction: TextInputAction.next,
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              textInputAction: TextInputAction.done,
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration:  InputDecoration(
                  labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (validateFields()) {
                  var user = await DatabaseHelper.instance.loginUser(usernameController.text, passwordController.text);
                  if (user != null) {
                    await SharedPreferences.getInstance().then((prefs) {
                      prefs.setString('dist_code', distCode);
                      prefs.setString('username', user['username']);
                      prefs.setBool('isLoggedIn', true);
                    });

                    // Check the value of eorderbookuser
                    int eorderbookuser = user['eorderbookuser'];

                    if (eorderbookuser == 1) {
                      await SharedPreferences.getInstance().then((prefs) {
                        prefs.setInt('eorderbookuser', user['eorderbookuser']);
                      });
                      await Utils.showLoaderDialog(context ,"Logging In", "Please wait..." );
                      Utils.showToast('Login successful');
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) =>  InvoiceListScreen()),
                      );
                    } else if (eorderbookuser == 2) {
                      await SharedPreferences.getInstance().then((prefs) {
                        prefs.setInt('eorderbookuser', user['eorderbookuser']);
                      });
                      await Utils.showLoaderDialog(context ,"Logging In", "Please wait..." );
                      Utils.showToast('Login successful');
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) =>  SalesDetails()),
                      );
                    }  else if (eorderbookuser == 3) {
                      await SharedPreferences.getInstance().then((prefs) {
                        prefs.setInt('eorderbookuser', user['eorderbookuser']);
                      });
                      await Utils.showLoaderDialog(context ,"Logging In", "Please wait..." );
                      Utils.showToast('Login successful');
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) =>  OrderDetailsLogin()),
                      );
                    } else {
                      // Handle other cases if needed
                    Utils.showToast('Account not Active');
                    }
                  } else {
                    Utils.showToast('Login Failed');
                  }
                }
              },
              child: const Text('Login'),
            )

          ],
        ),
      ),
    );
  }

  // Future<void> _showDistributorDialog() async {
  //   TextEditingController distCodeController = TextEditingController();
  //
  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Enter Distributor Code'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextFormField(
  //               controller: distCodeController,
  //               keyboardType: TextInputType.number,
  //               autofocus: true,
  //               decoration: const InputDecoration(labelText: 'Distributor Code'),
  //             ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             onPressed: () async {
  //               if (distCodeController.text.isNotEmpty) {
  //                 // Check if the entered dist_code is available
  //                 bool distCodeAvailable = await ApiService().checkDistCodeAvailability(distCodeController.text);
  //
  //                 if (distCodeAvailable) {
  //                   Navigator.of(context).pop();
  //                   await getData(distCodeController.text);
  //
  //                   // Store the distributor code in the local database
  //                   DistcodeDatabaseHelper().insertDistCode(distCodeController.text);
  //                 } else {
  //                   Utils.showToast('${distCodeController.text} not available. Please enter a valid code.');
  //                 }
  //               } else {
  //                 Utils.showToast('Please enter a distributor code');
  //               }
  //             },
  //             child: const Text('Sync Data'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  Future<void> _showDistributorDialog() async {
    TextEditingController distCodeController = TextEditingController();
    TextEditingController securityKeyController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Distributor Code and Security Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: distCodeController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Distributor Code'),
              ),
              TextFormField(
                controller: securityKeyController,
                obscureText: true,
                textInputAction: TextInputAction.send,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Security Key'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                if (distCodeController.text.isNotEmpty && securityKeyController.text.isNotEmpty) {
                  // Validate dist_code and security_key
                  ApiService apiService = ApiService();
                  bool isValid = await apiService.validateDistCode(distCodeController.text, securityKeyController.text);

                  if (isValid) {
                    Navigator.of(context).pop();
                    await getData(distCodeController.text);

                    _fetchMainCode(distCodeController.text);

                    // Store the distributor code in the local database
                    DistcodeDatabaseHelper().insertDistCode(distCodeController.text);

                    // Store the value of check_lic_expdate in shared preferences
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String checkLicExpDate = await apiService.getCheckLicExpDate(distCodeController.text);
                    prefs.setString('check_lic_expdate', checkLicExpDate);
                    print('fff $checkLicExpDate');
                  } else {
                    Utils.showToast('Invalid distributor code or security key.');
                  }
                } else {
                  Utils.showToast('Please enter both distributor code and security key');
                }
                await _getDistCode();
              },
              child: Text('Sync Data'),
            ),


          ],
        );
      },
    );
  }



  bool isLoading = false;

  getData(String distCode) async {
    setState(() {
      isLoading = true;
    });
    // Utils.showLoaderDialog(context, "Syncing data", "Please wait...");
    await Utils.showLoaderDialog(context ,"Syncing data", "Please wait..." );

    bool val = await _syncData(distCode);
    if (val == true) {
      isLoading = false;
    }
    Navigator.pop(context);
    setState(() {});
  }

  Future<bool> _syncData(String distCode) async {
    if (distCode.isEmpty) {
      Utils.showToast('Please enter a distributor code');
      return false;
    }

    try {
      debugPrint(distCode);
      ApiService apiService = ApiService();
      await apiService.syncData(distCode);
      Utils.showToast('Sync successful');
      this.distCode = distCode;
    } catch (e) {
      Utils.showToast('${e}Sync failed');
      debugPrint('Error syncing data: $e');
      return false;
    }
    return true;
  }

  bool validateFields() {
    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Utils.showToast('All fields are required');
      return false;
    }
    return true;
  }
}
