import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoiceDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ProductWIse extends StatefulWidget {
  final String mainCode;
  final String distCode;
  final String startDate;
  final String endDate;
  ProductWIse({required this.mainCode,required this.distCode,required this.startDate, required this.endDate});

  @override
  _ProductWIseState createState() => _ProductWIseState();
}

class _ProductWIseState extends State<ProductWIse> {


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
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_stock_product.php?&dist_code=${widget.distCode}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        responseData.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
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

  double calculateqty() {
    double totalAmount = 0.0;

    for (var item in profitinvoices) {
      totalAmount += double.tryParse(item['qty'].toString()) ?? 0.0;
    }

    return totalAmount;
  }
  double calculatebns() {
    double totalAmount = 0.0;

    for (var item in profitinvoices) {
      totalAmount += double.tryParse(item['bonus'].toString()) ?? 0.0;
    }

    return totalAmount;
  }
  double calculateqtyisue() {
    double totalAmount = 0.0;

    for (var item in profitinvoices) {
      totalAmount += double.tryParse(item['qtyissued'].toString()) ?? 0.0;
    }

    return totalAmount;
  }
  double calculateTotalBalance() {
    double totalAmount = 0.0;

    for (var item in profitinvoices) {
      final qty = calculateqty();
      final bns = calculatebns();
      final qtyIssue = calculateqtyisue();
      totalAmount += (qty + bns) - qtyIssue;
    }

    return totalAmount;
  }
  double calculateTotalAmount() {
    double totalAmount = 0.0;

    for (var item in profitinvoices) {
      final double pcrt = double.tryParse(item['pcrt'].toString()) ?? 0.0;
      final totalBal = calculateTotalBalance();
      totalAmount += (totalBal * pcrt);
    }

    return totalAmount;
  }
  TextEditingController searchController = TextEditingController();
  void searchInvoices(String query) {
    setState(() {
      if (query.isNotEmpty) {
        profitinvoices = originalInvoices.where((invoice) {
          // Check if the query is contained within the 'pcode' or 'name' fields
          return invoice['pcode'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['name'].toString().toLowerCase().contains(query.toLowerCase());
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
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Product Wise'),
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

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchInvoices('');
                        },
                      ),
                    ),
                    onChanged: (value) {
                      searchInvoices(value);
                    },
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
                            Text('Dis1: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('Dis2: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('Net Rate: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('P Bal: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('L Bal: ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text('Amt: ',
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
                      final double qty = double.tryParse(invoice['qty'].toString()) ?? 0.0;
                      final double pcrt = double.tryParse(invoice['pcrt'].toString()) ?? 0.0;
                      final double rate = double.tryParse(invoice['rate'].toString()) ?? 0.0;
                      final double dip1 = double.tryParse(invoice['dip1'].toString()) ?? 0.0;
                      final double dip2 = double.tryParse(invoice['dip2'].toString()) ?? 0.0;
                      final double bns = double.tryParse(invoice['bonus'].toString()) ?? 0.0;
                      final int unit = int.tryParse(invoice['unit'].toString()) ?? 0;
                      final double qtyissue = double.tryParse(invoice['qtyissued'].toString()) ?? 0.0;
                      final double totalbalance = (qty + bns) - qtyissue;
                      final double lBal =(unit > 0) ? (totalbalance % unit) : 0;
                      final double amount = totalbalance * pcrt;
                      final double netRate = unit * pcrt;
                      final double rates = unit * rate;

                      final double pBal = (unit > 0) ? (totalbalance / unit) : 0.0;
                      return Column(
                        children: [
                          Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text('${invoice['name']} (${invoice['pcode']}) (${invoice['unit']})',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('${rates.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${dip1.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${dip2.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${netRate.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${pBal.toInt()}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${lBal.toInt()}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${amount.toStringAsFixed(2)}',
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
              ],
            ),
          ),
        ),


        // bottomNavigationBar: Card(
        //   child: Padding(
        //     padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
        //     child: isLoading == true || profitinvoices.isEmpty
        //         ? null // Show circular progress indicator if loading or order data is empty
        //         : Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Text(
        //           'Total Stock Value :',
        //           style: TextStyle(
        //             fontSize: 20,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //         Text(
        //           'Rs. ${calculateTotalAmount()}',
        //           style: TextStyle(
        //             fontSize: 20,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // )
    );
  }
}
