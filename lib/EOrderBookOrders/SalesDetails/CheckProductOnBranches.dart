import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CheckProductOnBranches extends StatefulWidget {
  final String mainCode;
  final String distCode;
  final String startDate;
  final String endDate;
  CheckProductOnBranches({
    required this.mainCode,
    required this.distCode,
    required this.startDate,
    required this.endDate,
  });

  @override
  _CheckProductOnBranchesState createState() => _CheckProductOnBranchesState();
}

class _CheckProductOnBranchesState extends State<CheckProductOnBranches> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> profitinvoices = [];
  List<dynamic> profitinvoicesName = [];
  List<dynamic> originalInvoices = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await fetchProfit('');
  }

  Future<void> fetchProfit(String searchQuery) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_product_names.php?dist_code=${widget.distCode}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        responseData.sort((a, b) =>
            (a['name'] as String).compareTo(b['name'] as String));
        setState(() {
          profitinvoicesName = responseData;
          originalInvoices = List.from(profitinvoicesName);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchProductData(String productName) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_stock_product_main_distributor.php?main_code=${widget.mainCode}&name=$productName');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          profitinvoices = responseData;
        });
      } else {
        throw Exception('Failed to load product data');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Search Product on All Branches'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return originalInvoices
                    .where((invoice) =>
                    invoice['name']
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()))
                    .map<String>((invoice) => invoice['name'] as String)
                    .toList();
              },
              onSelected: (String selected) {
                _searchController.text = selected;
                fetchProductData(selected); // Call API with selected product name
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                _searchController = textEditingController;
                return TextField(
                  controller: _searchController,
                  focusNode: focusNode,
                  onSubmitted: (value) {
                    onFieldSubmitted();
                    fetchProductData(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Enter a product name',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () async {
                        _searchController.clear();
                        setState(() {
                          profitinvoices.clear();
                          profitinvoicesName.clear();
                        });
                        await _refreshData();
                      },
                    ),
                    border: OutlineInputBorder(),
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      constraints: BoxConstraints(
                        maxHeight: 500,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            // if (profitinvoices.isEmpty) ...[
            //   Expanded(
            //     child: Center(
            //       child: CircularProgressIndicator(),
            //     ),
            //   ),
            // ],
            if (profitinvoices.isNotEmpty) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: profitinvoices.length,
                  itemBuilder: (BuildContext context, int index) {
                    final invoice = profitinvoices[index];
                    final double qty =
                        double.tryParse(invoice['qty'].toString()) ?? 0.0;
                    final double pcrt =
                        double.tryParse(invoice['pcrt'].toString()) ?? 0.0;
                    final double rate =
                        double.tryParse(invoice['rate'].toString()) ?? 0.0;
                    final double dip1 =
                        double.tryParse(invoice['dip1'].toString()) ?? 0.0;
                    final double dip2 =
                        double.tryParse(invoice['dip2'].toString()) ?? 0.0;
                    final double bns =
                        double.tryParse(invoice['bonus'].toString()) ?? 0.0;
                    final int unit =
                        int.tryParse(invoice['unit'].toString()) ?? 0;
                    final double qtyissue =
                        double.tryParse(invoice['qtyissued'].toString()) ?? 0.0;
                    final double totalbalance =
                        (qty + bns) - qtyissue;
                    final double lBal = (unit > 0) ? (totalbalance % unit) : 0;
                    final double amount = totalbalance * pcrt;
                    final double netRate = unit * pcrt;
                    final double rates = unit * rate;
                    final double pBal = (unit > 0) ? (totalbalance / unit) : 0.0;

                    final bool isNewGroup = index == 0 ||
                        invoice['dist_name'] !=
                            profitinvoices[index - 1]['dist_name'];

                    return Column(
                      children: [
                        if (isNewGroup)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0),
                            child: Text(
                              invoice['dist_name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '${rates.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${dip1.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${dip2.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${netRate.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${pBal.toInt()}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${lBal.toInt()}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${amount.toStringAsFixed(2)}',
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
          ],
        ),
      ),
    );
  }
}
