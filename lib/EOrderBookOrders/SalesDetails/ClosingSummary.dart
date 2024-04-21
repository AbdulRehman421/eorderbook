import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CashIn.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CashOut.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoiceProfit.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoices.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClosingSummary extends StatefulWidget {
  final String mainCode;
  final String distCode;
  final String startDate;
  final String endDate;

  ClosingSummary({
    required this.mainCode,
    required this.distCode,
    required this.startDate,
    required this.endDate,
  });

  @override
  _ClosingSummaryState createState() => _ClosingSummaryState();
}

class _ClosingSummaryState extends State<ClosingSummary> {

  List<dynamic> cash = [];
  String? cstock;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    fetchCash(widget.distCode, widget.startDate, widget.endDate);
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






  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: cash.isNotEmpty
            ? Column(
          children: [
            Text(
               'Cash Book',
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
              cash.isNotEmpty
                  ? Expanded(
                child: ListView.builder(
                  itemCount: cash.length,
                  itemBuilder: (BuildContext context, int index) {
                    final invoice = cash[index];
                    double sale = double.parse(invoice['sale'] ?? '0');
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
                        Card(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Opening :',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${invoice['Opening']}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          color: Colors.amberAccent,
                        ),
                        GestureDetector(
                          onTap : (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CashIn(mainCode: widget.mainCode, distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate),));
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
                                    'Cash In / Recieved:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${invoice['cashIn']}',
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
                          onTap : (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CashOut(mainCode: widget.mainCode, distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate),));
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
                                    'Cash Out / Payment:',
                                    style: TextStyle(
                                      color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${invoice['cashOut']}',
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
                        Card(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Closing :',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    '${invoice['Closing']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                          color: Colors.amberAccent,
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
