import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/AllSalesDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/maincode.dart';
import '../../services/maincodedb.dart';

class SalesDetails extends StatefulWidget {
  @override
  _SalesDetailsState createState() => _SalesDetailsState();
}

class _SalesDetailsState extends State<SalesDetails> {
  TextEditingController mainCodeController = TextEditingController();
  // DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime startDate = DateTime(2021, 1, 1);


  void initState() {
    super.initState();
    _initializeDatabase();
  }

  bool _isLoading = false;
  List<dynamic> invoices = [];

  Future<void> fetchInvoices(
      String mainCode, String startDate, String endDate) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_inv.php?main_code=$mainCode&start_date=$startDate&end_date=$endDate');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          invoices = responseData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> showInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Enter Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Main Code : $_mainCode'),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? pickedStartDate =
                              await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );

                          final DateTime? pickedEndDate = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );

                          if (pickedStartDate != null &&
                              pickedEndDate != null) {
                            setState(() {
                              startDate = pickedStartDate;
                              endDate = pickedEndDate;
                            });
                          }
                        },
                        child: Text('Select Start and End Dates'),
                      ),
                      if (startDate != null && endDate != null)
                        Text(
                            '${startDate!.toString().split(' ')[0]} - ${endDate!.toString().split(' ')[0]}'),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Submit'),
                onPressed: () async {
                  var connectivityResult = await Connectivity().checkConnectivity();
                  if (connectivityResult == ConnectivityResult.none) {
                    // No internet connection
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('No internet connection'),
                    ));
                  } else {
                    // Internet connection available, proceed with the API call
                    _mainCode;
                    String formattedStartDate =
                    startDate.toIso8601String().split('T')[0];
                    String formattedEndDate =
                    endDate.toIso8601String().split('T')[0];
                    fetchInvoices(
                        _mainCode.toString(), formattedStartDate, formattedEndDate);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showInputDialog(context);
              },
              icon: Icon(Icons.date_range))
        ],
        title: Text('Invoice Viewer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            if(invoices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Main Code : $_mainCode',style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),),
                      SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? pickedStartDate =
                          await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );

                          final DateTime? pickedEndDate = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );

                          if (pickedStartDate != null &&
                              pickedEndDate != null) {
                            setState(() {
                              startDate = pickedStartDate;
                              endDate = pickedEndDate;
                            });
                          }
                        },
                        child: Text('Select Start and End Dates'),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      if (startDate != null && endDate != null)
                        Text(
                            '${startDate!.toString().split(' ')[0]}   to   ${endDate!.toString().split(' ')[0]}',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),),
                      SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                        child: _isLoading
                            ? CircularProgressIndicator() // Show CircularProgressIndicator when loading
                            : Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () async {
                          var connectivityResult = await Connectivity().checkConnectivity();
                          if (connectivityResult == ConnectivityResult.none) {
                            // No internet connection
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('No internet connection'),
                            ));
                          } else {
                            // Internet connection available, proceed with the API call
                            setState(() {
                              _isLoading = true; // Set loading state to true
                            });

                            _mainCode;
                            String formattedStartDate =
                            startDate.toIso8601String().split('T')[0];
                            String formattedEndDate =
                            endDate.toIso8601String().split('T')[0];
                            await fetchInvoices(
                                _mainCode.toString(), formattedStartDate, formattedEndDate);

                            setState(() {
                              _isLoading = false; // Reset loading state after API call completes
                            });
                          }
                        },
                      ),

                    ],
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: invoices.length,
                itemBuilder: (BuildContext context, int index) {
                  final invoice = invoices[index];
                  return GestureDetector(
                    onTap: () {
                      String formattedStartDate =
                          startDate.toIso8601String().split('T')[0];
                      String formattedEndDate =
                          endDate.toIso8601String().split('T')[0];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllSalesDetails(
                            mainCode: _mainCode.toString(),
                            startDate: formattedStartDate,
                            endDate: formattedEndDate,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${invoice['main_name']}',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Sale : ${invoice['net_sum']}", style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
