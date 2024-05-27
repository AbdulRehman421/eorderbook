import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/GetInvoiceDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class CashOut extends StatefulWidget {
  final String mainCode;
  final String distCode;
  final String startDate;
  final String endDate;
  CashOut({required this.mainCode,required this.distCode,required this.startDate, required this.endDate});

  @override
  _CashOutState createState() => _CashOutState();
}

class _CashOutState extends State<CashOut> {


  List<dynamic> profitinvoices = [];
  List<dynamic> originalInvoices = [];


  void initState(){
    super.initState();
    // fetchInvoices(widget.mainCode, widget.startDate, widget.endDate);
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
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_account_detail.php?&dist_code=${widget.distCode}&start_date=$startDate&end_date=$endDate&code=18');

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
  String getTextForInvoiceType(dynamic type) {
    if (type is int) {
      // Handle integer types
      switch (type) {
        case 33:
        case 3:
          return 'Sale';
        case 4:
        case 44:
        case 444:
          return 'S-Ret';
        case 1:
          return 'Pur';
        case 2:
          return 'Pur-Ret';
        case 13:
          return 'Transfer';
        case 0:
          return 'Opening';
        case 7:
        case 77:
        case 777:
          return 'CRV';
        case 6:
        case 66:
        case 666:
          return 'CPV';
        case 5:
        case 55:
          return 'JV';
        default:
          return ''; // Or any default text if no match found
      }
    } else if (type is String) {
      // Handle string types
      switch (type) {
        case '33':
        case '3':
          return 'Sale';
        case '4':
        case '44':
        case '444':
          return 'S-Ret';
        case '1':
          return 'Pur';
        case '2':
          return 'Pur-Ret';
        case '13':
          return 'Transfer';
        case '0':
          return 'Opening';
        case '7':
        case '77':
        case '777':
          return 'CRV';
        case '6':
        case '66':
        case '666':
          return 'CPV';
        case '5':
        case '55':
          return 'JV';
        default:
          return ''; // Or any default text if no match found
      }
    } else {
      return ''; // Handle other types if needed
    }
  }

  double calculateCredit() {
    double totalOrders = 0.0;

    for (var item in profitinvoices) {
      double profit = double.parse(item['credit']);
      totalOrders += profit;
    }

    return totalOrders;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
        profitinvoices.isNotEmpty
            ?Column(
          children: [
            Text('Cash Out / Payment')
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
              // Padding(
              //   padding: EdgeInsets.all(8.0),
              //   child: TextField(
              //     controller: searchController,
              //     decoration: InputDecoration(
              //       labelText: 'Search',
              //       suffixIcon: IconButton(
              //         icon: Icon(Icons.clear),
              //         onPressed: () {
              //           searchController.clear();
              //           searchInvoices('');
              //         },
              //       ),
              //     ),
              //     onChanged: (value) {
              //       searchInvoices(value);
              //     },
              //   ),
              // ),
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
                          Text('V No: ',
                            style: TextStyle(
                                          color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Text('Date: ',
                            style: TextStyle(
                                          color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Text('Type: ',
                            style: TextStyle(
                                          color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Text('Doc No: ',
                            style: TextStyle(
                                          color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Text('Credit: ',
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
                    // Convert 'credit' to a numeric type
                    final credit = double.tryParse(invoice['credit'] ?? '0') ?? 0;
                    // Check if 'credit' is greater than 0
                    if (credit > 0) {
                      return Column(
                        children: [
                          Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 20),
                                SizedBox(width: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      '${invoice['vno']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ), Text(
                                      '${invoice['invdt']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${getTextForInvoiceType(invoice['type'])}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${invoice['invno']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${credit.toStringAsFixed(2)}', // Display 'credit'
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                  ],
                                ),
                                Text(
                                  '         ${invoice['narration']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // If 'credit' is not greater than 0, return an empty container
                      return Container();
                    }
                  },
                ),
              ),


            ],
          ),
        ),
      ),
      bottomNavigationBar: Card(
        child: Padding(padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('  Credit Amount :', style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),),
        Text('${calculateCredit().toStringAsFixed(2)}  ', style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),),
          ],
        ),
        ),
      ),
    );
  }
}
