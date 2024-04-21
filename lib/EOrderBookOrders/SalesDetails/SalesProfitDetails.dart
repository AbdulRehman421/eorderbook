import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/ClosingStock.dart';
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
  List<dynamic> profitinvoices = [];
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
    fetchInvoice(widget.distCode, widget.startDate, widget.endDate);
    fetchCash(widget.distCode, widget.startDate, widget.endDate);
    fetchPayable(widget.distCode, widget.startDate, widget.endDate);
    fetchStock(widget.distCode);

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
        'https://seasoftsales.com/eorderbook/get_dist_sale.php?dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate');

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
    var invoiced = profitinvoices.isNotEmpty ? profitinvoices.first : null;
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
                                        Text(
                                          'Sales :',
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
                                        Text(
                                          'Sales Return :',
                                          style: TextStyle(
                                            color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          invoice['sale_return'],
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
                                          '$netPurchase',
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
