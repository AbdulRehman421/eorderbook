import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class GetInvoicesDetails extends StatefulWidget {
  final String mainCode;
  final String orderId;
  final String salesReturn;
  final String cash;
  final String name;
  final String title;
  String type;
  final String distCode;
  final String startDate;
  final String endDate;
  GetInvoicesDetails({required this.mainCode,required this.cash,required this.salesReturn,required this.orderId,required this.title,required this.name,required this.distCode,required this.type, required this.startDate, required this.endDate});

  @override
  _GetInvoicesDetailsState createState() => _GetInvoicesDetailsState();
}

class _GetInvoicesDetailsState extends State<GetInvoicesDetails> {


  // List<dynamic> invoices = [];
  List<dynamic> profitinvoices = [];
  void initState(){
    super.initState();
    // fetchInvoices(widget.mainCode, widget.startDate, widget.endDate);
    _refreshData();
  }
  Future<void> _refreshData() async {
    fetchProfit(widget.distCode, widget.startDate, widget.endDate);
  }

  Future<void> fetchProfit(String distcode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_invoice_detail.php?type=${widget.type}&dist_code=${widget.distCode}&order_id=${widget.orderId}');

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
  bool isLoading = false;

  double calculateRate() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double rate = double.parse(item['rate']);
      totalOrders += rate;
    }

    return totalOrders;
  }
  double calculateQty() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double qty = double.parse(item['qty']);
      totalOrders += qty;
    }

    return totalOrders;
  }
  double calculatedip1() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double dip1 = double.parse(item['dip1']);
      totalOrders += dip1;
    }

    return totalOrders;
  }
  double calculatedip2() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double dip2 = double.parse(item['dip2']);
      totalOrders += dip2;
    }

    return totalOrders;
  }
  double calculatenet() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double net = double.parse(item['net']);
      totalOrders += net;
    }

    return totalOrders;
  }



  @override
  Widget build(BuildContext context) {
    var invoiced = profitinvoices.isNotEmpty ? profitinvoices.first : null;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title:
          profitinvoices.isNotEmpty
              ?Column(
            children: [
              Text(widget.title)
            ],
          )
              : CircularProgressIndicator(),
        ),
        body:
        profitinvoices.isEmpty
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _refreshData,
              child: Center(
                        child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isLoading && profitinvoices.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20 , right: 20 , top: 20 , bottom: 20),
                      child: Container(
                        width: 500,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('Party Name :',style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                Flexible(child: Text(invoiced['name'],
                                  overflow: TextOverflow.ellipsis, // Handle overflow
                                  maxLines: 1,))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Address :',style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                Flexible(
                                  child: Text(
                                    invoiced['address'],
                                    overflow: TextOverflow.ellipsis, // Handle overflow
                                    maxLines: 1, // Limit to a single line
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Area :',style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                Text(invoiced['areaname'])
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Order No :',style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                Text(invoiced['invno'])
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Date :',style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                Text(invoiced['invdt'])
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!isLoading && profitinvoices.isNotEmpty)
                  Card(
                    color: Colors.lightGreenAccent,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20 , right: 20 , top: 5, bottom: 5),
                      child: Container(
                        width: 500,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Rate: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('Qty: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('Dip1: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('Dip2: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('Net: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: profitinvoices.length,
                    itemBuilder: (BuildContext context, int index) {
                      final invoice = profitinvoices[index];
                      return Column(
                        children: [
                          Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Row(
                                  children: [
                                    Text('       ${invoice['productname']} (${invoice['pcode']})',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('${invoice['rate']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['qty']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['dip1']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['dip2']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['net']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Card(
                  color: Colors.greenAccent,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
                      child: isLoading == true || profitinvoices.isEmpty
                          ? null // Show circular progress indicator if loading or order data is empty
                          :
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('${calculateRate().toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Text('${calculateQty().toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Text('${calculatedip1().toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Text('${calculatedip2().toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Text('${calculatenet().toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                        ],
                      )
                  ),
                ),
                Card(
                  color: Colors.greenAccent,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
                      child: isLoading == true || profitinvoices.isEmpty
                          ? null // Show circular progress indicator if loading or order data is empty
                          :
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Return : ${widget.salesReturn}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Text('Cash : ${widget.cash}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Text('STax :${invoiced['stax']}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Text('ITax :${invoiced['itax']}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                        ],
                      )
                  ),
                )
              ],
                        ),
                      ),
            ),

    );
  }
}
