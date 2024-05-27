import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RateChangeBills extends StatefulWidget {
  final String distCode;
  final String startDate;
  final String endDate;
  RateChangeBills({ required this.distCode, required this.startDate, required this.endDate});

  @override
  _RateChangeBillsState createState() => _RateChangeBillsState();
}

class _RateChangeBillsState extends State<RateChangeBills> {
  List<dynamic> profitinvoices = [];
  List<dynamic> originalInvoices = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await fetchProfit(widget.distCode, widget.startDate, widget.endDate);
  }

  Future<void> fetchProfit(String distcode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_rate_changed_invoices.php?type=33&dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          profitinvoices = responseData['order_details'];
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

  // Calculation functions...

  TextEditingController searchController = TextEditingController();

  void searchInvoices(String query) {
    setState(() {
      if (query.isNotEmpty) {
        profitinvoices = originalInvoices.where((invoice) {
          return invoice['productname'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['pcode'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['rate'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['qty'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['net'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['dip1'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['dip2'].toString().toLowerCase().contains(query.toLowerCase());
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Rate Change Bills'),
      ),
      body: profitinvoices.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: profitinvoices.length,
          itemBuilder: (BuildContext context, int index) {
            profitinvoices.sort((a, b) => a['invno'].compareTo(b['invno']));
            final invoice = profitinvoices[index];

            // Check if it is the first item of a new group
            final bool isNewGroup = index == 0 || invoice['invno'] != profitinvoices[index - 1]['invno'];

            return Column(
              children: [
                if (isNewGroup) ...[
                  SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: 500,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Party Name :',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    invoice['name'] ?? "",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date :',
                                  style: TextStyle(
                                      color: Colors.red.shade900,fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${invoice['invdt']} ${invoice['invtime']}' ?? "",
                                  style: TextStyle(
                                      color: Colors.red.shade900,fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Computer :',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${invoice['computer']}' ?? "",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Operator :',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${invoice['operator']}' ?? "",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'SalesMan :',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${invoice['smanname']}' ?? "",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Net :',
                                  style: TextStyle(
                                      color: Colors.red.shade900,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${invoice['net']}' ?? "",
                                  style: TextStyle(
                                      color: Colors.red.shade900,fontWeight: FontWeight.bold),
                                ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Container(
                          width: 500,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'MRP ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Rate ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Qty ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'D1 ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'D2 ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 20),
                      SizedBox(width: 20),
                      Row(
                        children: [
                          Text(
                            '       ${invoice['productname']} (${invoice['pcode']})',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '${invoice['rp']}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${invoice['rate']}',
                            style: TextStyle(color : Colors.red.shade900,fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${invoice['qty']}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${invoice['dip1']}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${invoice['dip2']}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }
}
