import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoiceDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Alerts/ModifiedBills/ModifiedSaleBills/ModifyBillSummary.dart';


class GetInvoices extends StatefulWidget {
  final String mainCode;
  final String name;
  final String title;
  String type;
  String type1;
  String type2;
  final String distCode;
  final String startDate;
  final String endDate;
  GetInvoices({required this.mainCode,required this.title,required this.name,required this.distCode,required this.type,required this.type1,required this.type2, required this.startDate, required this.endDate});

  @override
  _GetInvoicesState createState() => _GetInvoicesState();
}

class _GetInvoicesState extends State<GetInvoices> {


  // List<dynamic> invoices = [];
  List<dynamic> profitinvoices = [];
  List<dynamic> originalInvoices = [];

  void initState(){
    super.initState();
    // fetchInvoices(widget.mainCode, widget.startDate, widget.endDate);
    selectedType = widget.type;
    _refreshData();
  }
  bool isSearching = false;
  Future<void> _refreshData() async {
    setState(() {
      isSearching = true; // Set the flag to indicate searching is ongoing
    });
    await fetchProfit(widget.distCode, widget.startDate, widget.endDate);
    setState(() {
      isSearching = false; // Reset the flag when searching is finished
    });
  }
  Future<void> fetchProfit(String distcode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_invoice.php?type=${selectedType}&dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          profitinvoices = responseData;
          originalInvoices = List.from(profitinvoices); // Store original invoices for resetting

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
      // Check if 'gross' is not null before parsing
      if (item['gross'] != null) {
        double gross = double.parse(item['gross'].toString());
        totalOrders += gross;
      }
    }

    return totalOrders;
  }

  double calculated1() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      if (item['discount1'] != null) {
        double dis1 = double.parse(item['discount1'].toString());
        totalOrders += dis1;
      }
    }

    return totalOrders;
  }

  double calculated2() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      if (item['discount2'] != null) {
        double discount2 = double.parse(item['discount2'].toString());
        totalOrders += discount2;
      }
    }

    return totalOrders;
  }

  double calculatenet() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      if (item['net'] != null) {
        double net = double.parse(item['net'].toString());
        totalOrders += net;
      }
    }

    return totalOrders;
  }

  double calculatereturn() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      if (item['sale_return'] != null) {
        double saleReturn = double.parse(item['sale_return'].toString());
        totalOrders += saleReturn;
      }
    }

    return totalOrders;
  }

  double calculatecash() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      if (item['cash'] != null) {
        double cash = double.parse(item['cash'].toString());
        totalOrders += cash;
      }
    }

    return totalOrders;
  }

  TextEditingController searchController = TextEditingController();
  void searchInvoices(String query) {
    setState(() {
      if (query.isNotEmpty) {
        profitinvoices = originalInvoices.where((invoice) {
          // Check if the query matches the beginning of any field of the invoice
          return invoice['invno'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['gross'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['discount1'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['discount2'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['net'].toString().toLowerCase().contains(query.toLowerCase()) ||
              invoice['cash'].toString().toLowerCase().contains(query.toLowerCase());
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

  String selectedType = ''; // Newly added to track the selected type
bool loading = true;




  @override
  Widget build(BuildContext context) {
    var invoiced = profitinvoices.isNotEmpty ? profitinvoices.first : null;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${widget.title} Type      '),
            DropdownButton<String>(
              value: selectedType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedType = newValue!;
                  _refreshData();
                });
              },
              items: <String>[
                if (widget.type.isNotEmpty) widget.type,
                if (widget.type1.isNotEmpty) widget.type1,
                if (widget.type2.isNotEmpty) widget.type2,
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

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
                isSearching
                    ? Center(child: CircularProgressIndicator())
                    : profitinvoices.isEmpty
                    ? Center(child: Text('No data found'))
                    : Card(
                  color: Colors.green.shade900,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20 , right: 20 , top: 5, bottom: 5),
                    child: Container(
                      width: 500,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                           Text('Gross: ',
                                        style: TextStyle(
                                          color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                           Text('D1: ',
                                        style: TextStyle(
                                          color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                           Text('D2: ',
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
                           // Text('Return: ',
                           //              style: TextStyle(
                           //                  fontSize: 16,
                           //                  fontWeight: FontWeight.bold
                           //              ),),
                          Text('Cash: ',
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
                child: isSearching
                    ? Center(child: CircularProgressIndicator())
                    : profitinvoices.isEmpty
                    ? Center(child: Text('No data found'))
                    : ListView.builder(
                  itemCount: profitinvoices.length,
                  itemBuilder: (BuildContext context, int index) {
                    final invoice = profitinvoices[index];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap : (){
                            invoice['invtime'] == invoice['modifytime'] ?
                            Navigator.push(context, MaterialPageRoute(builder: (context) => GetInvoicesDetails(cash: invoice['cash'],salesReturn: invoice['sale_return'],mainCode: widget.mainCode, title: widget.title, name: widget.name, distCode: widget.distCode, type: widget.type, startDate: widget.startDate, endDate: widget.endDate, orderId: invoice['invno'],)))
                          : Navigator.push(context, MaterialPageRoute(builder: (context) => ModifiedBillSummary(startDate: widget.startDate,endDate: widget.endDate,distCode: widget.distCode,type: selectedType,invno: invoice['invno'],)));

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
                                        color: invoice['invtime'] == invoice['modifytime'] ? Colors.black : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    invoice['code'] == '1001'
                                    ?Text('   Cash',
                                      style: TextStyle(
                                          color: invoice['invtime'] == invoice['modifytime'] ? Colors.black : Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold
                                      ),)
                                        :Expanded(
                                          child: Text('   ${invoice['name']}',
                                                                              style: TextStyle(
                                                                                  color: invoice['invtime'] == invoice['modifytime'] ? Colors.black : Colors.white,
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
                                          color: invoice['invtime'] == invoice['modifytime'] ? Colors.black : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['discount1']}',
                                      style: TextStyle(
                                          color: invoice['invtime'] == invoice['modifytime'] ? Colors.black : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['discount2']}',
                                      style: TextStyle(
                                          color: invoice['invtime'] == invoice['modifytime'] ? Colors.black : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${invoice['net']}',
                                      style: TextStyle(
                                          color: invoice['invtime'] == invoice['modifytime'] ? Colors.black : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    // Text('${invoice['sale_return']}',
                                    //   style: TextStyle(
                                    //       fontSize: 16,
                                    //       fontWeight: FontWeight.bold
                                    //   ),),
                                    Text('${invoice['cash']}',
                                      style: TextStyle(
                                          color: invoice['invtime'] == invoice['modifytime'] ? Colors.black : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ],
                                )
                              ],
                            ),
                            color: invoice['invtime'] == invoice['modifytime'] ? Colors.white : Colors.red.shade900,
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
                // Text('${calculatereturn().toStringAsFixed(0)}',
                //   style: TextStyle(
                //       fontSize: 16,
                //       fontWeight: FontWeight.bold
                //   ),),
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
