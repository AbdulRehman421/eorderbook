import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoices.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  Widget build(BuildContext context) {
    var invoiced = profitinvoices.isNotEmpty ? profitinvoices.first : null;
    var invoicep = invoices.isNotEmpty ? invoices.first : null;

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
              style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              ?Expanded(
                child: ListView.builder(
                  itemCount: profitinvoices.length,
                  itemBuilder: (BuildContext context, int index) {
                    final invoice = profitinvoices[index];
                    double sale =
                    double.parse(invoice['sale'] ?? '0');
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
                          ),
                        ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GetInvoices(title: 'Sales Returns',name: invoice['name'],mainCode: widget.mainCode, distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate,type: '44'),));
                            },
                            child: Card(
                              child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Sales Return :',style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold
                                  ),),
                                  Text(invoice['sale_return'],style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold
                      ),)
                                ],
                              ),
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Net Sales :',style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold
                                ),),
                                Text('$netSale',style: TextStyle(
                                                fontSize: 18, fontWeight: FontWeight.bold
                                                ),)
                              ],
                            ),
                            ),
                            color: Colors.lightGreenAccent,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GetInvoices(title: 'Purchase',name: invoice['name'],mainCode: widget.mainCode, distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate,type: '1',),));
                            },
                            child: Card(
                              child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Purchase :',style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold
                                  ),),
                                  Text('${invoice['purchase']}',style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold
                      ),)
                                ],
                              ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GetInvoices(title: 'Purchase Returns',name: invoice['name'],mainCode: widget.mainCode, distCode: widget.distCode, startDate: widget.startDate, endDate: widget.endDate,type: '2'),));
                            },
                            child: Card(
                              child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Purchase Return :',style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold
                                    ),),
                                    Text('${invoice['purchase_return']}',style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold
                                    ),)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Net Purchase :',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),),
                                  Text('$netPurchase',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),)
                                ],
                              ),
                            ),color: Colors.lightGreenAccent,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Card(
                            child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Stock Transfer :',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),),
                                  Text('${invoice['sep']}',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),)
                                ],
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Closing Stock :',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),),
                                  Text('${cstock}',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),)
                                ],
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Gross Profit :',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),),
                                  Text('${calculateProfitValue().toStringAsFixed(2)} %',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),),
                                  Text('${double.parse(invoicep['profit'] ?? "0").toStringAsFixed(2)}',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),),
                                ],
                              ),
                            ),
                            color: Colors.lightGreenAccent,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Card(
                            child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Cash :',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),),
                                  Text('0',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),)
                                ],
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Recievable :',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),),
                                  Text('0',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),)
                                ],
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Payable :',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),),
                                  Text('0',style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold
                                  ),)
                                ],
                              ),
                            ),
                          ),

                        ],
                      );
                    },
                  ),
                )
                  :CircularProgressIndicator(),
              ],
            ),
          ),
        ),
    );
  }
}
