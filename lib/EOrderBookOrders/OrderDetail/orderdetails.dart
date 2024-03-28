import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/OrderDetail/ordermaps.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/distcodedb.dart';
import 'OrderDetailsScreen.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  void initState() {
    super.initState();
    _getDistCode();
    showInputDialog();
  }

  void dispose() {
    super.dispose();
  }

  String dist_Code = '0';

  Future<void> _getDistCode() async {
    String? distributorCode = await DistcodeDatabaseHelper().getDistributorCode();
    setState(() {
      dist_Code = distributorCode ?? '';
    });
  }

  Future<void> showInputDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');

    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

    setState(() {
      selectedStartDate = firstDayOfMonth;
      selectedEndDate = now;
    });

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
                  Text("Username : ${username.toString()}", style: TextStyle(fontSize: 18)),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedStartDate = await showDatePicker(
                        context: context,
                        initialDate: selectedStartDate!,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      final DateTime? pickedEndDate = await showDatePicker(
                        context: context,
                        initialDate: selectedEndDate!,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      if (pickedStartDate != null && pickedEndDate != null) {
                        setState(() {
                          selectedStartDate = pickedStartDate;
                          selectedEndDate = pickedEndDate;
                        });
                      }
                    },
                    child: Text('Select Start and End Dates'),
                  ),
                  if (selectedStartDate != null && selectedEndDate != null)
                    Text(
                      'Selected Dates: ${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year} - ${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}',
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
                      username.toString(),
                      selectedStartDate,
                      selectedEndDate,
                    );
                    // Clear selected dates
                    selectedStartDate = null;
                    selectedEndDate = null;
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
      String distCode, String userName, DateTime? startDate, DateTime? endDate) async {
    setState(() {
      isLoading = true;
    });

    if (startDate == null || endDate == null) {
      // Show a toast if start or end date is not selected
      Fluttertoast.showToast(
        msg: 'Please select both start and end dates.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    String formattedStartDate =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String formattedEndDate =
        "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    String apiUrl =
        'https://seasoftsales.com/eorderbook/get_orders2.php?dist_code=$distCode&user_name=$userName&start_date=$formattedStartDate&end_date=$formattedEndDate';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

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

  int calculateTotalOrders() {
    int totalOrders = 0;

    for (var item in orderData) {
      totalOrders += int.parse(item['orders']);
    }

    return totalOrders;
  }
  double calculateTotalOrderAmount() {
    double totalAmount = 0.0;

    for (var item in orderData) {
      totalAmount += double.parse(item['amount']);
    }

    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text('Order Details'),
        actions: [
          IconButton(
              onPressed: () {
                showInputDialog();
              },
              icon: Icon(Icons.calendar_month))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isLoading && orderData.isNotEmpty)
            Center(
                child: Text('Orders Amount : ${calculateTotalOrderAmount().toStringAsFixed(2)} (${calculateTotalOrders()})',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                )
            ),
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
                  return GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      final username = prefs.getString('username');
                      // When the card is tapped, navigate to OrderDetailsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(
                            distCode: dist_Code,
                            userName: username.toString(),
                            selectedDate: DateTime.parse(item['date']),  // Pass only the date from the tapped item
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
                          Text('${index + 1}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date : ${item['date']}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),),
                              Text("Orders Amount : ${item['amount']}  Total Order : ${item['orders']}",
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
          if (!isLoading && orderData.isEmpty)
            Center(
              heightFactor: 2,
              child: Lottie.asset(kIsWeb
                  ? 'not_found_data.json'
                  : 'assets/not_found_data.json'),
            ),
        ],
      ),
    );
  }
}
