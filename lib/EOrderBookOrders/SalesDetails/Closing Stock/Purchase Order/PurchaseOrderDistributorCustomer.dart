import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetCompanyProducts.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoiceDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'PurchaseOrderDistributorCustomerProduct.dart';


class PurchaseOrderDistributorCustomer extends StatefulWidget {
  final String mainCode;
  final String distCode;
  final String cdistCode;
  final String startDate;
  final String endDate;
  PurchaseOrderDistributorCustomer({required this.mainCode,required this.distCode,required this.startDate, required this.endDate , required this.cdistCode});

  @override
  _PurchaseOrderDistributorCustomerState createState() => _PurchaseOrderDistributorCustomerState();
}

class _PurchaseOrderDistributorCustomerState extends State<PurchaseOrderDistributorCustomer> {


  // List<dynamic> invoices = [];
  List<dynamic> profitinvoices = [];
  List<dynamic> originalInvoices = [];
  void initState(){
    super.initState();
    // fetchInvoices(widget.mainCode, widget.startDate, widget.endDate);
    _refreshData();
  }
  List<String> selectedCdistCodes = [];
  bool isSelectedAll = false;

  // Function to handle the onChanged event of individual checkboxes
  void handleCheckboxChange(bool? value, String cdistCode) {
    setState(() {
      if (value!) {
        selectedCdistCodes.add(cdistCode);
      } else {
        selectedCdistCodes.remove(cdistCode);
      }
    });
  }

  // Function to handle the onChanged event of "Select All" checkbox
  void toggleSelectAll(bool? value) {
    setState(() {
      isSelectedAll = value ?? false;
      if (isSelectedAll) {
        selectedCdistCodes.clear();
        // Add all cdistCodes to selectedCdistCodes when "Select All" is checked
        for (var invoice in profitinvoices) {
          selectedCdistCodes.add(invoice['companycode']);
        }
      } else {
        selectedCdistCodes.clear(); // Clear selectedCdistCodes when "Select All" is unchecked
      }
    });
  }
  Future<void> _refreshData() async {
    fetchProfit(widget.distCode, widget.startDate, widget.endDate);
  }
  Future<void> fetchProfit(String distcode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_stock_distributor_company.php?cdist_code=${widget.cdistCode}&dist_code=${widget.distCode}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        responseData.sort((a, b) => (a['companyname_name'] as String).compareTo(b['companyname_name'] as String));
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
          return invoice['companycode'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['companyname_name'].toString().toLowerCase().contains(query.toLowerCase());
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
          title: Text('Company Wise'),
          actions: [
            Row(
              children: [
                Text('Select All'),
                Checkbox(
                  value: isSelectedAll,
                  onChanged: toggleSelectAll,
                ),
              ],
            ),
          ],
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
                Expanded(
                  child: ListView.builder(
                    itemCount: profitinvoices.length,
                    itemBuilder: (BuildContext context, int index) {
                      final invoice = profitinvoices[index];
                      final cdistCode = invoice['companycode'];
                      // Determine checkbox state based on selectedCdistCodes list
                      bool isSelected = selectedCdistCodes.contains(cdistCode);
                      final double stock = double.tryParse(invoice['stock'].toString()) ?? 0.0;
                      return Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value!) {
                                        selectedCdistCodes.add(cdistCode);
                                      } else {
                                        selectedCdistCodes.remove(cdistCode);
                                      }
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text('${invoice['companyname_name']} (${invoice['companycode']})',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold
                                  ),),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('      Stock Value : ',style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                                Text('${stock.toStringAsFixed(2)}      ',style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                              ],
                            ),
                          ],
                        ),
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
            padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
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
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedCdistCodes.isNotEmpty) {
            List<String> selectedCodesAsString = selectedCdistCodes.map((code) => code.toString()).toList();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PurchaseOrderDistributorCustomerProduct(
                  cdistCode: widget.cdistCode,
                  mainCode: widget.mainCode,
                  distCode: widget.distCode,
                  compCode: selectedCodesAsString,
                ),
              ),
            );
          } else {
            // Show a message or handle the case when no company code is selected
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please select a company first.'),
              ),
            );
          }
        },
        child: Icon(Icons.navigate_next),
      ),
    );
  }
}
