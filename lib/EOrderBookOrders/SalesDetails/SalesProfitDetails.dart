import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/Alerts/AlertHome.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/ClosingStock.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/ClosingSummary.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoiceProfit.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoices.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/PayableBalance.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/RecievableBalance.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ExpiryStock/ExpiryStock.dart';

class SalesProfitDetails extends StatefulWidget {
  final String mainCode;
  final String distCode;
  final String startDate;
  final String endDate;

  SalesProfitDetails({
    required this.mainCode,
    required this.distCode,
    required this.startDate,
    required this.endDate,
  });

  @override
  _SalesProfitDetailsState createState() => _SalesProfitDetailsState();
}

class _SalesProfitDetailsState extends State<SalesProfitDetails> {
  List<dynamic> checkdistcode = [];
  List<dynamic> profitinvoices = [];
  List<dynamic> invoices4 = [];
  List<dynamic> invoices44 = [];
  List<dynamic> invoices444 = [];
  List<dynamic> profitinvoicesN = [];
  List<dynamic> invoices = [];
  List<dynamic> cash = [];
  List<dynamic> payableinvoices = [];
  List<dynamic> stock = [];
  List<dynamic> originalInvoices = [];
  String? cstock;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    fetchCStock(widget.distCode);
    fetchProfit(widget.distCode, widget.startDate, widget.endDate);
    fetchProfitN(widget.distCode, widget.startDate, widget.endDate);
    fetchInvoice(widget.distCode, widget.startDate, widget.endDate);
    fetchCash(widget.distCode, widget.startDate, widget.endDate);
    fetchPayable(widget.distCode, widget.startDate, widget.endDate);
    fetchStock(widget.distCode);
    fetchSaleReturn4(widget.distCode, widget.startDate, widget.endDate);
    fetchSaleReturn44(widget.distCode, widget.startDate, widget.endDate);
    fetchSaleReturn444(widget.distCode, widget.startDate, widget.endDate);
    checkDistCode(widget.distCode, widget.startDate, widget.endDate);

  }

  Future<void> checkDistCode(String distcode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_distcode.php?dist_code=$distcode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          checkdistcode = responseData;
          originalInvoices = List.from(checkdistcode); // Store original invoices for resetting

        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> fetchSaleReturn4(String distcode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_invoice.php?type=4&dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          invoices4 = responseData;
          originalInvoices = List.from(invoices4); // Store original invoices for resetting

        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> fetchSaleReturn44(String distcode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_invoice.php?type=44&dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          invoices44 = responseData;
          originalInvoices = List.from(invoices44); // Store original invoices for resetting

        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> fetchSaleReturn444(String distcode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_invoice.php?type=444&dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          invoices444 = responseData;
          originalInvoices = List.from(invoices444); // Store original invoices for resetting

        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  double calculatenet4() {
    double totalOrders = 0.0;

    for (var item in invoices4) {
      if (item['net'] != null) {
        double net = double.parse(item['net'].toString());
        totalOrders += net;
      }
    }

    return totalOrders;
  }
  double calculatenet44() {
    double totalOrders = 0.0;

    for (var item in invoices44) {
      if (item['net'] != null) {
        double net = double.parse(item['net'].toString());
        totalOrders += net;
      }
    }

    return totalOrders;
  }
  double calculatenet444() {
    double totalOrders = 0.0;

    for (var item in invoices444) {
      if (item['net'] != null) {
        double net = double.parse(item['net'].toString());
        totalOrders += net;
      }
    }

    return totalOrders;
  }
  Future<void> fetchPayable(String distcode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_account_balance.php?&dist_code=${widget.distCode}&end_date=$endDate&code=18');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          payableinvoices = responseData;
          originalInvoices = List.from(profitinvoices); // Store original invoices for resetting

        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> fetchProfit(
      String distcode, String startDate, String endDate) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_dist_sale.php?dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate&retailinv=y');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          profitinvoices = responseData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> fetchProfitN(
      String distcode, String startDate, String endDate) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_dist_sale.php?dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate&retailinv=n');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          profitinvoicesN = responseData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> fetchCash(
      String distcode, String startDate, String endDate ) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_account_summary.php?dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate&code=18');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          cash = responseData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchInvoice(
      String distcode, String startDate, String endDate) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_dist_sale_profit.php?dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate');

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
  Future<void> fetchStock(
      String distcode) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_stock.php?days=$_customValue&dist_code=$distcode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          stock = responseData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchCStock(String distCode) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_maincode.php?dist_code=$distCode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          cstock = jsonData['cstock'];
        });
      } else {
        throw Exception('Failed to load cstock');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  double calculateProfitNet() {
    double totalOrders = 0.0;

    for (var item in invoices) {
      double gross = double.parse(item['gross'] ?? '0');
      double dis1 = double.parse(item['discount1'] ?? '0');
      double dis2 = double.parse(item['discount2'] ?? '0');
      totalOrders += gross - dis1 - dis2;
    }

    return totalOrders;
  }

  double calculateProfitValue() {
    double totalOrders = 0.0;

    for (var item in invoices) {
      double gross = double.parse(item['profit'] ?? '0');
      totalOrders = gross / calculateProfitNet() * 100;
    }

    return totalOrders;
  }

  double calculatePayable() {
    double totalBalance = 0.0;

    for (var invoice in payableinvoices) {
      double balance = double.parse(invoice['balance']);
      if (balance < 0) {
        totalBalance += balance;
      }
    }

    return totalBalance;
  }
  double calculateRecievable() {
    double totalBalance = 0.0;

    for (var invoice in payableinvoices) {
      double balance = double.parse(invoice['balance']);
      if (balance > 0) {
        totalBalance += balance;
      }
    }

    return totalBalance;
  }
  int _customValue = 180;

  Future<void> _openDialog() async {
    int? newValue = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int? enteredValue;
        return AlertDialog(
          title: Center(child: Text('Enter Days')),
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
    }
  }


  @override
  Widget build(BuildContext context) {
    print('dd ${widget.distCode}');
    var invoiced = profitinvoices.isNotEmpty ? profitinvoices.first : null;
    var checkDist = checkdistcode.isNotEmpty ? checkdistcode.first : null;
    var invoicedN = profitinvoicesN.isNotEmpty ? profitinvoicesN.first : null;
    var invoicep = invoices.isNotEmpty ? invoices.first : null;
    var cashI = cash.isNotEmpty ? cash.first : null;
    var stockExpire = stock.isNotEmpty ? stock.first : null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: profitinvoices.isNotEmpty
            ? Column(
                children: [
                  Text(
                    invoiced['name'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.startDate}   to  ${widget.endDate}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              )
            : CircularProgressIndicator(),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              profitinvoices.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: profitinvoices.length,
                        itemBuilder: (BuildContext context, int index) {
                          final invoice = profitinvoices[index];
                          double profit = double.parse(invoicep?['profit'] ?? "0");
                          double sale = double.parse(invoice['sale'] ?? '0');
                          // double invoiceSale = double.parse(invoicedN['sale'] ?? '0');
                          // double saleN = double.parse(invoicedN['sale'] ?? '');
                          double stocks = double.parse(stockExpire['stock'] ?? '0');
                          double saleReturn =
                              double.parse(invoice['sale_return'] ?? '0');
                          double netSale = sale - saleReturn;
                          double purchase =
                              double.parse(invoice['purchase'] ?? '0');
                          double purchaseReturn =
                              double.parse(invoice['purchase_return'] ?? '0');
                          double netPurchase = purchase - purchaseReturn;
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GetInvoices(
                                        title: 'Sales',
                                        name: invoice['name'] ?? '',
                                        mainCode: widget.mainCode,
                                        distCode: widget.distCode,
                                        startDate: widget.startDate,
                                        endDate: widget.endDate,
                                        type: '33',
                                        type1: '333',
                                        type2: '',
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text('Counter Sale   ',
                                              style: TextStyle(
                                                    fontSize: 13,
                                                  fontWeight: FontWeight.bold),),
                                                Text('Whole Sale     ',
                                              style: TextStyle(
                                                    fontSize: 13,
                                                  fontWeight: FontWeight.bold),),

                                              ],crossAxisAlignment: CrossAxisAlignment.start,
                                            ),
                                            Column(
                                              children: [
                                                Text('${sale.toInt()}',
                                              style: TextStyle(
                                                    fontSize: 13,
                                                  fontWeight: FontWeight.bold),),
                                                Text(
                                                  '${invoicedN != null ? invoicedN['sale'] ?? '0' : '0'}',
                                                  style: TextStyle(
                                                    fontSize: 13,fontWeight: FontWeight.bold),
                                                ),


                                              ],crossAxisAlignment: CrossAxisAlignment.end,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [

                                            Text(
                                              'Sales :  ',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              invoice['sale'] ?? '',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  color: Colors.greenAccent,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GetInvoices(
                                            title: 'Sales Returns',
                                            name: invoice['name'],
                                            mainCode: widget.mainCode,
                                            distCode: widget.distCode,
                                            startDate: widget.startDate,
                                            endDate: widget.endDate,
                                            type: '444',
                                            type1: '44',
                                            type2: '4',

                                        ),
                                      ));
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text('Counter Sale   ',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                      fontWeight: FontWeight.bold),),
                                                Text('Whole Sale     ',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                      fontWeight: FontWeight.bold),),
                                                Text('Open Return     ',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                      fontWeight: FontWeight.bold),),

                                              ],crossAxisAlignment: CrossAxisAlignment.start,
                                            ),
                                            Column(
                                              children: [
                                                Text('${calculatenet44().toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                      fontWeight: FontWeight.bold),),
                                                Text('${calculatenet4().toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                      fontWeight: FontWeight.bold),),
                                                Text('${calculatenet444().toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                      fontWeight: FontWeight.bold),),

                                              ],crossAxisAlignment: CrossAxisAlignment.end,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Return :  ',
                                              style: TextStyle(
                                                    color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              invoice['sale_return'] ?? '',
                                              style: TextStyle(
                                                    color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //       'Sales Return :',
                                    //       style: TextStyle(
                                    //         color: Colors.white,
                                    //           fontSize: 18,
                                    //           fontWeight: FontWeight.bold),
                                    //     ),
                                    //     Text(
                                    //       invoice['sale_return'],
                                    //       style: TextStyle(
                                    //           color: Colors.white,
                                    //           fontSize: 18,
                                    //           fontWeight: FontWeight.bold),
                                    //     )
                                    //   ],
                                    // ),
                                  ),
                                  color: Colors.redAccent,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GetInvoices(
                                        title: 'Sales',
                                        name: invoice['name'] ?? '',
                                        mainCode: widget.mainCode,
                                        distCode: widget.distCode,
                                        startDate: widget.startDate,
                                        endDate: widget.endDate,
                                        type: '33',
                                        type1: '333',
                                        type2: '',
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Net Sales :',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '$netSale',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                  color: Colors.lightBlueAccent.shade100,
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GetInvoices(
                                          title: 'Purchase',
                                          name: invoice['name'],
                                          mainCode: widget.mainCode,
                                          distCode: widget.distCode,
                                          startDate: widget.startDate,
                                          endDate: widget.endDate,
                                          type: '1',
                                          type1: '',
                                          type2: '',
                                        ),
                                      ));
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Purchase :',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${invoice['purchase']}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                  color: Colors.greenAccent,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GetInvoices(
                                            title: 'Purchase Returns',
                                            name: invoice['name'],
                                            mainCode: widget.mainCode,
                                            distCode: widget.distCode,
                                            startDate: widget.startDate,
                                            endDate: widget.endDate,
                                            type: '2',
                                            type1: '',
                                            type2: '',
                                        ),
                                      ));
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Purchase Return :',
                                          style: TextStyle(
                                            color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${invoice['purchase_return']}',
                                          style: TextStyle(
                                            color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                  color: Colors.redAccent,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GetInvoices(
                                          title: 'Purchase',
                                          name: invoice['name'],
                                          mainCode: widget.mainCode,
                                          distCode: widget.distCode,
                                          startDate: widget.startDate,
                                          endDate: widget.endDate,
                                          type: '1',
                                          type1: '',
                                          type2: '',
                                        ),
                                      ));
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Net Purchase :',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${netPurchase.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                  color: Colors.lightBlueAccent.shade100,
                                ),
                              ),
                              SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AlertsHome(distCode: widget.distCode,endDate: widget.endDate,startDate: widget.startDate,),));
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Center(
                                      child: Text(
                                        'A L E R T S',
                                        style: TextStyle(
                                          color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Card(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap : (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ExpiryStock(days: _customValue.toString(),mainCode: widget.mainCode, distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate),))     ;

                                        },
                                        child: Text(
                                          'Near Expiry \nStock within :',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      InkWell(
                                        child: Row(
                                          children: [
                                            Text('$_customValue  Days',
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
                                      GestureDetector(
                                        onTap : (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ExpiryStock(days: _customValue.toString(),mainCode: widget.mainCode, distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate),))     ;

                                        },
                                        child: Text(
                                          '${stocks.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ),
                              GestureDetector(
                                onTap : (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ClosingStock(mainCode: widget.mainCode, distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate),))  ;
                          },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Closing Stock :',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${cstock}',
                                          style: TextStyle(

                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GetInvoiceProfit(
                                            title: "Gross Profit",
                                            name: invoice['name'],
                                            mainCode: widget.mainCode,
                                            distCode: widget.distCode,
                                            type: '33',
                                            startDate: widget.startDate,
                                            endDate: widget.endDate),
                                      ));
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Gross Profit :',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${calculateProfitValue().toStringAsFixed(2)} %',
                                          style: TextStyle(
                                            color: Colors.green,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            '${profit.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              if(checkDist['showaccountsdetail'] == 'Y')
                              GestureDetector(
                                onTap : (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ClosingSummary(mainCode: widget.mainCode, distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate),));
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Cash upto ${widget.endDate}:',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${cashI['Closing']}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                  
                                ),
                              ),
                              if(checkDist['showaccountsdetail'] == 'Y')
                              GestureDetector(
                                onTap : (){
                                  Navigator.push(context,  MaterialPageRoute(builder: (context) => RecievableBalance(mainCode: widget.mainCode, distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate),));
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Recievable :',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${calculateRecievable().toStringAsFixed(2)}  ',
                                          style: TextStyle(
                                            color: Colors.green,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if(checkDist['showaccountsdetail'] == 'Y')
                              GestureDetector(
                                onTap : (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => PayabaleBalance(mainCode: widget.mainCode, distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate),));
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Payable :',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${calculatePayable().toStringAsFixed(2)}  ',
                                          style: TextStyle(
                                            color: Colors.red,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
