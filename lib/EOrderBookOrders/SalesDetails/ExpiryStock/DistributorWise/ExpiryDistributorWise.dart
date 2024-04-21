import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/DistributorCompanyWise.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetCompanyProducts.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoiceDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../CompanyWise.dart';
import 'ExpiryDistributorCompanyWise.dart';

class ExpiryDistributorWIse extends StatefulWidget {
  final String mainCode;
  final String distCode;
  final String days;
  final String startDate;
  final String endDate;

  ExpiryDistributorWIse(
      {required this.mainCode,
      required this.distCode,
      required this.days,
      required this.startDate,
      required this.endDate});

  @override
  _ExpiryDistributorWIseState createState() => _ExpiryDistributorWIseState();
}

class _ExpiryDistributorWIseState extends State<ExpiryDistributorWIse> {
  // List<dynamic> invoices = [];
  List<dynamic> profitinvoices = [];
  List<dynamic> originalInvoices = [];

  void initState() {
    super.initState();
    // fetchInvoices(widget.mainCode, widget.startDate, widget.endDate);
    _refreshData();
  }

  Future<void> _refreshData() async {
    fetchProfit(widget.distCode, widget.startDate, widget.endDate);
  }

  Future<void> fetchProfit(
      String distcode, String startDate, String endDate) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_stock_distributor.php?days=${widget.days}&dist_code=${widget.distCode}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        responseData.sort((a, b) =>
            (a['dist_name'] as String).compareTo(b['dist_name'] as String));
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

  double calculateStock() {
    double totalAmount = 0.0;

    for (var item in profitinvoices) {
      totalAmount += double.parse(item['stock']);
    }

    return totalAmount;
  }

  // double calculateSale() {
  //   double totalOrders = 0.0;
  //
  //   for (var item in profitinvoices) {
  //     double gross = double.parse(item['net']);
  //     totalOrders += gross;
  //   }
  //
  //   return totalOrders;
  // }
  TextEditingController searchController = TextEditingController();

  void searchInvoices(String query) {
    setState(() {
      if (query.isNotEmpty) {
        profitinvoices = originalInvoices.where((invoice) {
          // Check if the query is contained within the 'pcode' or 'name' fields
          return invoice['cdist_code']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              invoice['dist_name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
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
          title: Text('Distributor Wise'),
        ),
        body: profitinvoices.isEmpty
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshData,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                      Expanded(
                        child: ListView.builder(
                          itemCount: profitinvoices.length,
                          itemBuilder: (BuildContext context, int index) {
                            final invoice = profitinvoices[index];
                            final double stock =
                                double.tryParse(invoice['stock'].toString()) ??
                                    0.0;
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ExpiryDistributorCompanyWIse(
                                                days: widget.days,
                                                  mainCode: widget.mainCode,
                                                  distCode: widget.distCode,
                                                  startDate: widget.startDate,
                                                  endDate: widget.endDate,
                                                cdistCode: invoice['cdist_code'],
                                              ),
                                        ));
                                  },
                                  child: Card(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              '${invoice['dist_name']} (${invoice['cdist_code']})',
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '      Stock Value : ',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${stock.toStringAsFixed(2)}      ',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
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
        bottomNavigationBar: Card(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
            child: isLoading == true || profitinvoices.isEmpty
                ? null // Show circular progress indicator if loading or order data is empty
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Stock Value :',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rs. ${calculateStock().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}
