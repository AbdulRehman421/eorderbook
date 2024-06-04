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
  List<dynamic> originalInvoices = [];

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
          originalInvoices = List.from(profitinvoices);
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
  double calculateTotalPurchase() {
    double totalPurchase = 0.0;
    for (final invoice in profitinvoices) {
      final qty = int.parse(invoice['qty']);
      final bonus = int.parse(invoice['bonus']);
      final pcrt = double.parse(invoice['pcrt']);
      final purchase = (qty + bonus) * pcrt;
      totalPurchase += purchase;
    }
    return totalPurchase;
  }

  double calculateBonus() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double qty = double.parse(item['bonus']);
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
  double calculategross() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double dip2 = double.parse(item['gross']);
      totalOrders += dip2;
    }

    return totalOrders;
  }
  double calculated1() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double dip2 = double.parse(item['discount1']);
      totalOrders += dip2;
    }

    return totalOrders;
  }
  double calculated2() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double dip2 = double.parse(item['discount2']);
      totalOrders += dip2;
    }

    return totalOrders;
  }
  // double calculatenet() {
  //   double totalOrders = 0.0;
  //
  //   for (var item in profitinvoices) {
  //     final gross = calculategross();
  //     final discount1 = calculated1();
  //     final discount2 = calculated2();
  //     totalOrders = gross - discount1 - discount2;
  //   }
  //
  //   return totalOrders;
  // }

  double calculatenet() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double net = double.parse(item['net']);
      totalOrders += net;
    }

    return totalOrders;
  }
  double calculatepcrt() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double net = double.parse(item['pcrt']);
      totalOrders += net;
    }

    return totalOrders;
  }
  
  double calculatePurValue() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      final qty = calculateQty();
      final bonus = calculateBonus();
      final pcrt = calculatepcrt();
      totalOrders = ( qty + bonus ) * pcrt;
    }

    return totalOrders;
  }
  double calculateProfit() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double profit = double.parse(item['netpp']);
      totalOrders += profit;
    }

    return totalOrders;
  }
  double calculatePercentage() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      final profit = calculateProfit();
      double net = double.parse(item['net']);
      totalOrders = (profit / net) * 100;
    }

    return totalOrders;
  }
  TextEditingController searchController = TextEditingController();
  void searchInvoices(String query) {
    setState(() {
      if (query.isNotEmpty) {
        profitinvoices = originalInvoices.where((invoice) {
          // Check if the query matches any part of any field of the invoice
          return invoice['productname'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['pcode'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['rate'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['qty'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['net'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['dip1'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['dip2'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        // If the query is empty, reset to the original list of invoices
        profitinvoices = List.from(originalInvoices);
      }

      // Check if there are no search results, display a message instead of removing data
      if (profitinvoices.isEmpty && query.isNotEmpty) {
        profitinvoices.add({'message': 'No data found for \"$query\"'});
      }
    });
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
                                Flexible(child: Text(invoiced['name'] ?? "",style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),
                                  overflow: TextOverflow.ellipsis, // Handle overflow
                                  maxLines: 1,))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Bill No :',style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                Text(invoiced['invno'] ?? "",style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Date :',style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                Text('${invoiced['DATE(i.invdt)']}${invoiced['invtime']}' ?? "",style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),)
                              ],
                            ),
                            if(invoiced['date(i.modifydate)'] != '2000-01-01')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Modify Date :',style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                Text('${invoiced['date(i.modifydate)']}${invoiced['modifytime']}' ?? "",style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Computer :',style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                Text('${invoiced['computer']}' ?? "",style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Operator :',style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                Text('${invoiced['operator']}' ?? "",style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('SalesMan :',style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                Text('${invoiced['smanName']}' ?? "",style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!isLoading && profitinvoices.isNotEmpty)
                  Card(
                    color: Colors.green.shade900,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20 , right: 20 , top: 5, bottom: 5),
                      child: Container(
                        width: 500,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Rate: ',
                              style: TextStyle(
                                          color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('Qty: ',
                              style: TextStyle(
                                          color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('Net: ',
                              style: TextStyle(
                                          color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            widget.title == "Gross Profit"
                        ?Text('Pur Value:',
                        style: TextStyle(
                                          color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),)
                            :Text('Dip1: ',
                              style: TextStyle(
                                          color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            widget.title == "Gross Profit"
                                ?Text('Profit:',
                              style: TextStyle(
                                          color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),)
                                :
                            Text('Dip2: ',
                              style: TextStyle(
                                          color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                                Text(

                                  widget.title == "Gross Profit"
                                  ? '%age: ' : '',
                              style: TextStyle(
                                  color: Colors.white,
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
                      final int qty = invoice['qty'] != null ? int.parse(invoice['qty']) : 0;
                      final double rate = invoice['rate'] != null ? double.parse(invoice['rate']) : 0.0;
                      final double bonus = invoice['bonus'] != null ? double.parse(invoice['bonus']) : 0.0;
                      final double profit = invoice['netpp'] != null ? double.parse(invoice['netpp']) : 0.0;
                      final double pcrt = invoice['pcrt'] != null ? double.parse(invoice['pcrt']) : 0.0;
                      final double dip1 = invoice['dip1'] != null ? double.parse(invoice['dip1']) : 0.0;
                      final double dip2 = invoice['dip2'] != null ? double.parse(invoice['dip2']) : 0.0;
                      final double net = invoice['net'] != null ? double.parse(invoice['net']) : 0.0;

                      final purchase = (qty + bonus) * pcrt;
                      final gross = qty * rate;
                      final d1 = gross * dip1 / 100;
                      final d2 = (gross - d1) * dip2 / 100;
                      final netValue = gross - d1 - d2;
                      final percentageValue = (profit / netValue ) * 100;
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
                                    Text('${netValue.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    widget.title == "Gross Profit"
                                    ?Text("${purchase.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),)
                                        :Text('${invoice['dip1']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    widget.title == "Gross Profit"
                                    ?Text('${profit.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),)
                                        :Text('${invoice['dip2']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    widget.title == "Gross Profit"
                                        ?Text('${percentageValue.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),)
                                        : SizedBox(),

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
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                widget.title == "Gross Profit"
                                ? 'Net' : 'Gross',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),),
                              Text(
                                widget.title == "Gross Profit"
                                    ? 'Pur Value' : 'D1',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),),
                              Text(
                                widget.title == "Gross Profit"
                                    ? 'Profit' : 'D2',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),),
                              Text(
                                widget.title == "Gross Profit"
                                    ? '%age' : 'Net',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(widget.title == "Gross Profit"
                                  ?'${invoiced['net'] ?? ""}' : invoiced['gross'] ?? "",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                              Text(widget.title == "Gross Profit"
                                  ?'${calculateTotalPurchase().toStringAsFixed(2)}' : invoiced['discount1'] ?? "",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                              Text(widget.title == "Gross Profit"
                                  ?'${calculateProfit().toStringAsFixed(2)}' : invoiced['discount2'] ?? "",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                              Text(widget.title == "Gross Profit"
                                  ?'${calculatePercentage().toStringAsFixed(2)}' : invoiced['net'] ?? "",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          widget.title == "Gross Profit"
                          ? Container()
                          :Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Return : ${widget.salesReturn}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ),),
                              Text('Cash : ${widget.cash}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ),),
                              Text('STax :${invoiced['stax']}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ),),
                              Text('ITax :${invoiced['itax']}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ),),
                            ],
                          )
                        ],
                      )
                  ),
                ),
              ],
                        ),
                      ),
            ),

    );
  }
}
