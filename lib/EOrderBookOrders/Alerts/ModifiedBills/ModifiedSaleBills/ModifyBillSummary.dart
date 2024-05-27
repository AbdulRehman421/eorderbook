import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/Alerts/ModifiedBills/ModifiedSaleBills/ModifiedBillDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ModifiedBillSummary extends StatefulWidget {
  final String invno;
  final String type;
  final String distCode;
  final String startDate;
  final String endDate;

  ModifiedBillSummary({required this.distCode,required this.invno, required this.type, required this.startDate, required this.endDate});

  @override
  _ModifiedBillSummaryState createState() => _ModifiedBillSummaryState();
}

class _ModifiedBillSummaryState extends State<ModifiedBillSummary> {
  List<dynamic> profitinvoices = [];
  List<dynamic> originalInvoices = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      isSearching = true;
    });
    await fetchProfit(widget.distCode, widget.startDate, widget.endDate);
    setState(() {
      isSearching = false;
    });
  }

  Future<void> fetchProfit(String distcode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_modified_invoices_summary.php?invno=${widget.invno}&type=${widget.type}&dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          profitinvoices = responseData['order_details'];  // Access the "order_details" field
          originalInvoices = List.from(profitinvoices);   // Store original invoices for resetting
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  double calculateTotal(String key) {
    double total = 0.0;
    for (var item in profitinvoices) {
      if (item[key] != null) {
        total += double.parse(item[key].toString());
      }
    }
    return total;
  }

  void searchInvoices(String query) {
    setState(() {
      if (query.isNotEmpty) {
        profitinvoices = originalInvoices.where((invoice) {
          return invoice['invno'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['gross'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['discount1'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['discount2'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['net'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['cash'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        profitinvoices = List.from(originalInvoices);
      }

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
        title:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Inv# : ${invoiced['invno']}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ),),

          ],
        ),

      ),
      body:
      profitinvoices.isEmpty
          ? Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text('No Data Found',style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18
          ),),
        ],
      ))
          : RefreshIndicator(
        onRefresh: _refreshData,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // if (profitinvoices.isNotEmpty)
              //   isSearching
              //       ? Center(child: CircularProgressIndicator())
              //       : profitinvoices.isEmpty
              //       ? Center(child: Text('No data found'))
              //       : Card(
              //     color: Colors.green.shade900,
              //     child: Padding(
              //       padding: const EdgeInsets.only(left: 20 , right: 20 , top: 5, bottom: 5),
              //       child: Container(
              //         width: 500,
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //           children: [
              //             Text('Gross: ',
              //               style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold
              //               ),),
              //             Text('D1: ',
              //               style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold
              //               ),),
              //             Text('D2: ',
              //               style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold
              //               ),),
              //             Text('Net: ',
              //               style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold
              //               ),),
              //             // Text('Return: ',
              //             //              style: TextStyle(
              //             //                  fontSize: 16,
              //             //                  fontWeight: FontWeight.bold
              //             //              ),),
              //             Text('Cash: ',
              //               style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold
              //               ),),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              Expanded(
                child: isSearching
                    ? Center(child: CircularProgressIndicator())
                    : profitinvoices.isEmpty
                    ? Center(child: Text('No data found'))
                    : ListView.builder(
                  itemCount: profitinvoices.length,
                  itemBuilder: (BuildContext context, int index) {
                    profitinvoices.sort((a, b) => a['srno'].compareTo(b['srno']));
                    final invoice = profitinvoices[index];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap : (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ModifiedBillDetails(orderId: widget.invno, distCode: widget.distCode, type: widget.type, startDate: widget.startDate, endDate: widget.endDate),));
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
                                    // invoice['code'] == '1001'
                                    //     ?Text('        Cash',
                                    //   style: TextStyle(
                                    //       fontSize: 14,
                                    //       fontWeight: FontWeight.bold
                                    //   ),)
                                    //     :
                                    Expanded(
                                      child: Text('        ${invoice['name']}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('       Invoice Date',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['invdt']}   ${invoice['invtime']}   ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('       Computer',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['computer']}   ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('       Operator',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['operator']}   ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('       Sales Man',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['smanname']}   ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     Text('       Modified Date',
                                //       style: TextStyle(
                                //           fontSize: 16,
                                //           fontWeight: FontWeight.bold
                                //       ),),
                                //     Text('${invoice['modifydate']} ${invoice['modifytime']}   ',
                                //       style: TextStyle(
                                //           fontSize: 16,
                                //           fontWeight: FontWeight.bold
                                //       ),),
                                //   ],
                                // ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('       Net',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['net']}   ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                ),
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

      // bottomNavigationBar: Card(
      //   color: Colors.greenAccent,
      //   child: Padding(
      //       padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
      //       child: profitinvoices.isEmpty
      //           ? null // Show circular progress indicator if loading or order data is empty
      //           :
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //         children: [
      //           Text('${calculategross().toStringAsFixed(0)}',
      //             style: TextStyle(
      //                 fontSize: 16,
      //                 fontWeight: FontWeight.bold
      //             ),),
      //           Text('${calculated1().toStringAsFixed(0)}',
      //             style: TextStyle(
      //                 fontSize: 16,
      //                 fontWeight: FontWeight.bold
      //             ),),
      //           Text('${calculated2().toStringAsFixed(0)}',
      //             style: TextStyle(
      //                 fontSize: 16,
      //                 fontWeight: FontWeight.bold
      //             ),),
      //           Text('${calculatenet().toStringAsFixed(0)}',
      //             style: TextStyle(
      //                 fontSize: 16,
      //                 fontWeight: FontWeight.bold
      //             ),),
      //           // Text('${calculatereturn().toStringAsFixed(0)}',
      //           //   style: TextStyle(
      //           //       fontSize: 16,
      //           //       fontWeight: FontWeight.bold
      //           //   ),),
      //           Text('${calculatecash().toStringAsFixed(0)}',
      //             style: TextStyle(
      //                 fontSize: 16,
      //                 fontWeight: FontWeight.bold
      //             ),),
      //         ],
      //       )
      //   ),
      // )
    );
  }
}
