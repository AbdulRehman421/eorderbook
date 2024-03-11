import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/ordermaps.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/distcodedb.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  DateTime? selectedDate;

  void initState() {
    super.initState();
    _getDistCode();
    showInputDialog();
    selectedDate = DateTime.now();
  }
  void dispose(){
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
    selectedDate = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');

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
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        // Save selected date to SharedPreferences
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
                      username.toString(),
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
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text('Order Details'),
        actions: [
          IconButton(onPressed: () {
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
        visible: !isLoading && orderData.isNotEmpty,
        child: FloatingActionButton.extended(onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final username = prefs.getString('username');
          Navigator.push(context, MaterialPageRoute(builder: (context) => OrderMap(distcode: dist_Code, username: username.toString(),),));
        },
        label: Text('Map View'),
        ),
      ),
    );
  }
}
