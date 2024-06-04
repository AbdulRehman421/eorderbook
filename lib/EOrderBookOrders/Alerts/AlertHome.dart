import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/Alerts/ModifiedBills/ModifiedBillsHome.dart';
import 'package:eorderbook/EOrderBookOrders/Alerts/RateChangeBills/RateChangeBills.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'DiscountProducts/DiscountProducts.dart';

class AlertsHome extends StatefulWidget {
  final String distCode;
  final String startDate;
  final String endDate;

  const AlertsHome({
    required this.distCode,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<AlertsHome> createState() => _AlertsHomeState();
}

class _AlertsHomeState extends State<AlertsHome> {
  Map<String, dynamic> profitinvoices = {};
  Map<String, dynamic> profitinvoices2 = {};
  Map<String, dynamic> profitinvoices3 = {};
  int _customValue = 10;
  int lowProfit = 5;
  List<dynamic> discount = [];

  @override
  void initState() {
    super.initState();
    fetchProfit();
    fetchProfit2();
    fetchProfit3();
  }
  Future<void> fetchStock(
      String distcode) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_stock.php?days=$_customValue&dist_code=$distcode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          discount = responseData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> _openDialog() async {
    int? newValue = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int? enteredValue;
        return AlertDialog(
          title: Center(child: Text('Enter Percentage')),
          content: TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              enteredValue = int.tryParse(value);
            },
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(enteredValue);
                },
                child: Text('OK'),
              ),
            ),
          ],
        );
      },
    );

    if (newValue != null && newValue != _customValue) {
      setState(() {
        _customValue = newValue!;
      });

      // Execute fetchStock(widget.distCode) here
      fetchStock(widget.distCode);
      fetchProfit3();
    }
  }
  Future<void> _openDialogProfit() async {
    int? newValue = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int? enteredValue;
        return AlertDialog(
          title: Center(child: Text('Enter Percentage')),
          content: TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              enteredValue = int.tryParse(value);
            },
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(enteredValue);
                },
                child: Text('OK'),
              ),
            ),
          ],
        );
      },
    );

    if (newValue != null && newValue != lowProfit) {
      setState(() {
        lowProfit = newValue!;
      });

      // Execute fetchStock(widget.distCode) here
      fetchStock(widget.distCode);
      fetchProfit3();
    }
  }

  Future<void> fetchProfit() async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_modified_invoice_nos.php?start_date=${widget.startDate}&dist_code=${widget.distCode}&end_date=${widget.endDate}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);  // Log the response body
        if (responseData is Map<String, dynamic>) {
          setState(() {
            profitinvoices = responseData;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> fetchProfit2() async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_rate_changed_invoices_nos.php?start_date=${widget.startDate}&dist_code=${widget.distCode}&end_date=${widget.endDate}&type=33');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);  // Log the response body
        if (responseData is Map<String, dynamic>) {
          setState(() {
            profitinvoices2 = responseData;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> fetchProfit3() async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_discounted_products_nos.php?start_date=${widget.startDate}&dist_code=${widget.distCode}&end_date=${widget.endDate}&type=33&dip=${_customValue}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);  // Log the response body
        if (responseData is Map<String, dynamic>) {
          setState(() {
            profitinvoices3 = responseData;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Alerts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(context,  MaterialPageRoute(builder: (context) => ModifiedBillsHome(distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate),));
              },
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        'Modified Bills',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        '${profitinvoices['total_invoices'] ?? '0'}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RateChangeBills(distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate),));
              },
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        'Rate Change Products',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        '${profitinvoices2['total_invoices'] ?? '0'}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountedProducts(distCode: widget.distCode,endDate: widget.endDate,startDate: widget.startDate,dip: _customValue.toString(),),));
              },
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        'Discount >',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    InkWell(
                      child: Row(
                        children: [
                          Text('$_customValue  %',
                            style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),),
                        ],
                      ),
                      onTap: () {
                        _openDialog();
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        '${profitinvoices3['total_products'] ?? '0'}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // GestureDetector(
            //   onTap: () {},
            //   child: Card(
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Padding(
            //           padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            //           child: Text(
            //             'Profit < ',
            //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //         InkWell(
            //           child: Row(
            //             children: [
            //               Text('$lowProfit  %',
            //                 style: TextStyle(
            //                     color: Colors.red.shade700,
            //                     fontSize: 20,
            //                     fontWeight: FontWeight.bold),),
            //             ],
            //           ),
            //           onTap: () {
            //             _openDialogProfit();
            //           },
            //         ),
            //         Padding(
            //           padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            //           child: Text(
            //             '${profitinvoices3['total_products'] ?? '0'}',
            //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
