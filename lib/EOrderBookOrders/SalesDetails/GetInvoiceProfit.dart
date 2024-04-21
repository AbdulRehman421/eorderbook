import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoiceDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class GetInvoiceProfit extends StatefulWidget {
  final String mainCode;
  final String name;
  final String title;
  String type;
  final String distCode;
  final String startDate;
  final String endDate;
  GetInvoiceProfit({required this.mainCode,required this.title,required this.name,required this.distCode,required this.type, required this.startDate, required this.endDate});

  @override
  _GetInvoiceProfitState createState() => _GetInvoiceProfitState();
}

class _GetInvoiceProfitState extends State<GetInvoiceProfit> {


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
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_invoice_profit.php?type=${widget.type}&dist_code=${widget.distCode}&start_date=${widget.startDate}&end_date=${widget.endDate}');

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

  double calculateSale() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double gross = double.parse(item['net']);
      totalOrders += gross;
    }

    return totalOrders;
  }
  double calculatePur() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double dis1 = double.parse(item['pur_value']);
      totalOrders += dis1;
    }

    return totalOrders;
  }
  double calculateProfit() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double discount2 = double.parse(item['profit']);
      totalOrders += discount2;
    }

    return totalOrders;
  }
  double calculatePercentage() {
    double totalProfit = calculateProfit();
    double totalSale = calculateSale();

    if(totalSale == 0) {
      return 0; // Avoid division by zero
    }

    double percentage = (totalProfit / totalSale) * 100;
    return percentage;
  }



  @override
  Widget build(BuildContext context) {
    var invoiced = profitinvoices.isNotEmpty ? profitinvoices.first : null;
    print("calc ${calculatePercentage()}");
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
                Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5 , horizontal : 60,),
                    child: Column(
                      children: [
                        Text(widget.name,style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),),
                        Text('From  ${widget.startDate}   to  ${widget.endDate}',style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),),
                      ],
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
                            Text('Sale Value: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('Pur value: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('Profit: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('%age: ',
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
                      final double net = double.parse(invoice['net'].toString());
                      final double purValue = double.parse(invoice['pur_value'].toString());
                      final double profit = double.parse(invoice['profit'].toString());
                      final double percentageValue = (profit / net) * 100;
                      return Column(
                        children: [
                          GestureDetector(
                            onTap : (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GetInvoicesDetails(cash: invoice['cash'],salesReturn: invoice['sale_return'],mainCode: widget.mainCode, title: widget.title, name: widget.name, distCode: widget.distCode, type: widget.type, startDate: widget.startDate, endDate: widget.endDate, orderId: invoice['invno'],)));
                            },
                            child: Card(
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
                                      Text('       Inv# : ${invoice['invno']}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                                      invoice['code'] == '1001'
                                          ?Text('   Cash',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold
                                        ),)
                                          :Expanded(
                                        child: Text('   ${invoice['name']}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text('${net.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                                      Text('${purValue.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                                      purValue == 0
                                      ?Text('0.00',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),)
                                      :Text('${profit.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                                      purValue == 0
                                          ?Text('0%',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),)
                                      :Text('${percentageValue.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        bottomNavigationBar: Card(
          color: Colors.greenAccent,
          child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
              child: isLoading == true || profitinvoices.isEmpty
                  ? null // Show circular progress indicator if loading or order data is empty
                  :
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('${calculateSale().toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),),
                  Text('${calculatePur().toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),),
                  Text('${calculateProfit().toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),),
                  Text('${calculatePercentage().toStringAsFixed(2)}%',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),),
                ],
              )
          ),
        )
    );
  }
}
