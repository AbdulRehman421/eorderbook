import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoiceDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class GetInvoices extends StatefulWidget {
  final String mainCode;
  final String name;
  final String title;
  String type;
  final String distCode;
  final String startDate;
  final String endDate;
  GetInvoices({required this.mainCode,required this.title,required this.name,required this.distCode,required this.type, required this.startDate, required this.endDate});

  @override
  _GetInvoicesState createState() => _GetInvoicesState();
}

class _GetInvoicesState extends State<GetInvoices> {


  // List<dynamic> invoices = [];
  List<dynamic> profitinvoices = [];
  void initState(){
    super.initState();
    // fetchInvoices(widget.mainCode, widget.startDate, widget.endDate);
    _refreshData();
  }
  Future<void> _refreshData() async {;
  fetchProfit(widget.distCode, widget.startDate, widget.endDate);
  }
  Future<void> fetchProfit(String distcode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_invoice.php?type=${widget.type}&dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate');

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

  double calculategross() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double gross = double.parse(item['gross']);
      totalOrders += gross;
    }

    return totalOrders;
  }
  double calculated1() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double dis1 = double.parse(item['discount1']);
      totalOrders += dis1;
    }

    return totalOrders;
  }
  double calculated2() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double discount2 = double.parse(item['discount2']);
      totalOrders += discount2;
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
  double calculatereturn() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double sale_return = double.parse(item['sale_return']);
      totalOrders += sale_return;
    }

    return totalOrders;
  }
  double calculatecash() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double cash = double.parse(item['cash']);
      totalOrders += cash;
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
                           Text('Gross: ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                           Text('D1: ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                           Text('D2: ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                           Text('Net: ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                           Text('Return: ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                          Text('Cash: ',
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
                                    Text('${invoice['gross']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['discount1']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['discount2']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['net']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['sale_return']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['cash']}',
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
                Text('${calculategross().toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),),
                Text('${calculated1().toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),),
                Text('${calculated2().toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),),
                Text('${calculatenet().toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),),
                Text('${calculatereturn().toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),),
                Text('${calculatecash().toStringAsFixed(0)}',
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
