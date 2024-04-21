import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoiceDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class CheckProductOnBranches extends StatefulWidget {
  final String mainCode;
  final String distCode;
  final String startDate;
  final String endDate;
  CheckProductOnBranches({required this.mainCode,required this.distCode,required this.startDate, required this.endDate});

  @override
  _CheckProductOnBranchesState createState() => _CheckProductOnBranchesState();
}

class _CheckProductOnBranchesState extends State<CheckProductOnBranches> {


  List<dynamic> profitinvoices = [];
  List<dynamic> originalInvoices = [];
  void initState(){
    super.initState();
    _refreshData();
  }
  Future<void> _refreshData() async {
    // fetchProfit(widget.distCode, widget.startDate, widget.endDate);
  }
  Future<void> fetchProfit(String distcode, String startDate, String endDate, String searchQuery) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_stock_product_main_distributor.php?main_code=${widget.mainCode}&name=${searchQuery}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        responseData.sort((a, b) => (a['dist_name'] as String).compareTo(b['dist_name'] as String)); // Sort by dist_name
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
  // void searchInvoices(String query) {
  //   setState(() {
  //     if (query.isNotEmpty) {
  //       profitinvoices = originalInvoices.where((invoice) {
  //         // Check if the query is contained within the 'pcode' or 'name' fields
  //         return invoice['pcode'].toString().toLowerCase().contains(query.toLowerCase()) ||
  //             invoice['name'].toString().toLowerCase().contains(query.toLowerCase());
  //       }).toList();
  //     } else {
  //       // If the query is empty, reset to the original list of invoices
  //       profitinvoices = List.from(originalInvoices);
  //     }
  //
  //     // Check if there are no search results, display a message instead of removing data
  //     if (profitinvoices.isEmpty && query.isNotEmpty) {
  //       profitinvoices.add({'message': 'No data found for \"$query\"'});
  //     }
  //   });
  // }
  void searchInvoices(String query) {
    setState(() {
      if (query.isNotEmpty) {
        // Fetch data from the server based on the search query
        fetchProfit(widget.distCode, widget.startDate, widget.endDate, query);
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
          title: Text('Search Product on All Branches'),
        ),
        body:RefreshIndicator(
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
                      hintStyle: TextStyle(fontSize: 18),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchInvoices('');
                        },
                      ),
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          searchInvoices(searchController.text);
                        },
                      ),
                    ),
                    // onChanged: (value) {
                    //   searchInvoices(value);
                    // },
                    onSubmitted: (value) {
                      searchInvoices(value);
                    },
                    textInputAction: TextInputAction.search,
                  ),
                ),
                if (profitinvoices.isNotEmpty)
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
                      final double lBal = (unit > 0) ? (totalbalance % unit) : 0;
                      final double amount = totalbalance * pcrt;
                      final double netRate = unit * pcrt;
                      final double rates = unit * rate;
                      final double pBal = (unit > 0) ? (totalbalance / unit) : 0.0;

                      // Check if this invoice's dist_name is different from the previous one
                      final bool isNewGroup = index == 0 || invoice['dist_name'] != profitinvoices[index - 1]['dist_name'];

                      return Column(
                        children: [
                          // Show the dist_name as a header if it's a new group
                          if (isNewGroup)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                invoice['dist_name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          // Show the invoice details
                          Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 20),
                                    Text(
                                      '${invoice['name']} (${invoice['pcode']}) (${invoice['unit']})',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('${rates.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('${dip1.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('${dip2.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('${netRate.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('${pBal.toInt()}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('${lBal.toInt()}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('${amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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
