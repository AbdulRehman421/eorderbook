import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/Inovice/InvoiceData.dart';
import 'package:eorderbook/EOrderBookOrders/Inovice/invoice.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/DBHelper/OrdersDB.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/DBHelper/ProductsDB.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/Model/OrderModel.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/Model/ProductsModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../../../utils/Utils.dart';

class PurchaseOrderDistributorCustomerProduct extends StatefulWidget {
  final String mainCode;
  final String? order;
  final String distCode;
  final String cdistCode;
  final List<String> compCode;

  PurchaseOrderDistributorCustomerProduct({
    this.order,
    required this.mainCode,
    required this.distCode,
    required this.cdistCode,
    required this.compCode,
  });

  @override
  _PurchaseOrderDistributorCustomerProductState createState() =>
      _PurchaseOrderDistributorCustomerProductState();
}

class _PurchaseOrderDistributorCustomerProductState
    extends State<PurchaseOrderDistributorCustomerProduct> {
  final dbHelper = DBHelperProduct();
  final dbHelpers = DBHelperOrder();
  List<Product> _products = [];
  List<Order> _orders = [];
  List<ProductMonthSale> _salesData = [];
  List<ProductMonthPur> _purData = [];
  bool _dataSent = false;

  @override
  void initState() {
    super.initState();
    fetchDataAndStoreLocally();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<dynamic> profitinvoices = [];
  List<dynamic> originalInvoices = [];
  bool _sortByCompanyName = false;
  bool _showOrderProducts = false;

  Future<void> fetchProfit(String distcode, String pCode) async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_product_monthwise_sale.php?dist_code=$distcode&pcode=$pCode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
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

  Future<void> fetchPurNo() async {
    try {
      final response = await http.get(Uri.parse(
          'https://seasoftsales.com/eorderbook/get_max_dpur_no.php?dist_code=${widget.distCode}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data'); // Debug print statement
        purNumber = data['next_pur_no'].toString();
        print('Max Pur Order Number: $purNumber'); // Debug print statement
      } else {
        throw Exception('Failed to fetch max pur order number');
      }
    } catch (error) {
      print(
          'Error fetching max pur order number: $error'); // Debug print statement
    }
  }

  Future<void> fetchOrdersDataAndStoreLocally() async {
    final response = await http.get(Uri.parse(
        'https://seasoftsales.com/eorderbook/get_pur_order_detail.php?dist_code=${widget.distCode}&order_id=$maxNumber'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _orders = data.map((item) => Order.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void fetchDataAndStoreLocally() async {
    String companyCodesString = widget.compCode.join(',');
    print('ddd ${companyCodesString}');

    // Construct the base URL
    String url = 'https://seasoftsales.com/eorderbook/get_stock_product_multi_company.php?companycode=${companyCodesString}&dist_code=${widget.distCode}';

    // Add the orderqty parameter only if widget.order is not null
    if (widget.order != null) {
      url += '&orderqty=${widget.order}';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      await dbHelper.clearProducts();
      for (var data in responseData) {
        final product = Product.fromJson(data);
        await dbHelper.insertProduct(product);
      }
      _products = await dbHelper.getProducts();

      // Sort the _products list based on the checkbox status

      setState(() {}); // Trigger a rebuild after fetching data
    } else {
      throw Exception('Failed to load data');
    }
  }

  String maxNumber = "";
  String purNumber = "";

  Future<void> fetchMaxPurOrderNo() async {
    try {
      final response = await http.get(Uri.parse(
          'https://seasoftsales.com/eorderbook/get_max_purorder_no.php'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data'); // Debug print statement
        maxNumber = data['next_pur_no'].toString();
        print('Max Pur Order Number: $maxNumber'); // Debug print statement
      } else {
        throw Exception('Failed to fetch max pur order number');
      }
    } catch (error) {
      print(
          'Error fetching max pur order number: $error'); // Debug print statement
    }
  }

  double calculateAmt() {
    double totalAmount = 0.0;

    for (var item in _products) {
      // totalAmount += (calculateOrder() * calculateRate()) - (calculateOrder() * calculateRate() * calculateDip() / 100);
      totalAmount += (double.parse(item.order) < 0
              ? 0
              : double.parse(item.order) * double.parse(item.rate)) -
          (double.parse(item.order) < 0
              ? 0
              : double.parse(item.order) *
                  double.parse(item.rate) *
                  double.parse(item.dip) /
                  100);
    }

    return totalAmount;
  }

  Future<void> _fetchSalesData(String pCode) async {
    try {
      final response = await http.get(Uri.parse(
          'https://seasoftsales.com/eorderbook/get_product_monthwise_sale.php?dist_code=${widget.distCode}&pcode=$pCode'));
      print('pcode : $pCode');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<ProductMonthSale> salesData = responseData
            .map((data) => ProductMonthSale.fromJson(data))
            .toList();
        setState(() {
          _salesData = salesData;
        });
      } else {
        throw Exception('Failed to load product monthwise sale data');
      }
    } catch (e) {
      print('Error fetching sales data: $e');
      // Handle error
    }
  }

  Future<void> _fetchPurData(String pCode) async {
    try {
      final response = await http.get(Uri.parse(
          'https://seasoftsales.com/eorderbook/get_invoice_detail.php?dist_code=${widget.distCode}&pcode=$pCode&type=1'));
      print('pcode : $pCode');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Sort the responseData list based on the date (i.invdt)
        responseData.sort((a, b) {
          // Assuming i.invdt is a String in the format 'YYYY-MM-DD'
          DateTime dateTimeA = DateTime.parse(a['date(i.invdt)']);
          DateTime dateTimeB = DateTime.parse(b['date(i.invdt)']);
          return dateTimeB.compareTo(dateTimeA);
        });

        List<ProductMonthPur> purData =
        responseData.map((data) => ProductMonthPur.fromJson(data)).toList();
        setState(() {
          _purData = purData;
        });
      } else {
        throw Exception('Failed to load product Purchase sale data');
      }
    } catch (e) {
      print('Error fetching Purchase sales data: $e');
      // Handle error
    }
  }


  // Future<void> sendDataToServer(List<Product> products) async {
  //   int purNo = DateTime.now().microsecond;
  //
  //   for (var product in products) {
  //     // Check if order is greater than 0
  //     if (double.parse(product.order) > 0) {
  //       // Convert Product object to JSON
  //       Map<String, dynamic> jsonData = product.toJson();
  //
  //       // Remove fields not required by the API
  //       jsonData.remove('minOrder');
  //       jsonData['bonus'] = '0'; // Set bonus to '0'
  //       jsonData['qty'] = product.order;
  //       jsonData['dpur_no'] = purNumber;
  //       jsonData['cdist_code'] = widget.cdistCode; // Set bonus to '0'
  //       jsonData['dist_code'] = widget.distCode; // Set bonus to '0'
  //       jsonData['date'] = DateTime.now().toIso8601String(); // Set bonus to '0' // Set minOrder to '0'
  //       jsonData['pur_no'] = maxNumber; // Assign the pur_no
  //
  //       // Convert JSON to string
  //       String jsonString = json.encode(jsonData);
  //
  //       // Send POST request to the server
  //       final response = await http.post(
  //         Uri.parse('https://seasoftsales.com/eorderbook/abc.php'),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json',
  //         },
  //         body: jsonString,
  //       );
  //
  //       // Check if the request was successful
  //       if (response.statusCode == 201) {
  //         print('Data inserted successfully');
  //       } else {
  //         print('Failed to insert data: ${response.body}');
  //       }
  //     }
  //   }
  // }

  Future<void> sendDataToServer(List<Product> products) async {
    var requests = <Future<bool>>[];
    bool dataSent = false;
    for (var product in products) {
      if (double.parse(product.order) > 0) {
        Map<String, dynamic> jsonData = product.toJson();
        jsonData.remove('minOrder');
        jsonData['bonus'] = '0';
        jsonData['qty'] = product.order;
        jsonData['dpur_no'] = purNumber;
        jsonData['cdist_code'] = widget.cdistCode;
        jsonData['dist_code'] = widget.distCode;
        jsonData['date'] = DateTime.now().toIso8601String();
        jsonData['pur_no'] = maxNumber;

        String jsonString = json.encode(jsonData);
        requests.add(_sendRequest(jsonString));
        dataSent = true;
      }
    }
    if (!dataSent) {
      Utils.showToast('No orders found');
      return; // No need to proceed further
    }
    List<bool> results = await Future.wait(requests);
    if (results.every((result) => result == true)) {
      Utils.showToast('Send successful');
    } else {
      Utils.showToast('Failed to send some data');
    }
  }

  Future<bool> _sendRequest(String jsonString) async {
    try {
      final response = await http.post(
        Uri.parse('https://seasoftsales.com/eorderbook/abc.php'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonString,
      );
      if (response.statusCode == 201) {
        print('Data inserted successfully');
        return true;
      } else {
        print('Failed to insert data: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending request: $e');
      return false;
    }
  }

  void _toggleSort(bool? newValue) {
    if (newValue != null) {
      // Check if newValue is not null
      setState(() {
        _sortByCompanyName =
            newValue; // Re-fetch data based on the new sorting preference
      });
    }
  }

  void _showOrderProduct(bool? newValue) {
    if (newValue != null) {
      // Check if newValue is not null
      setState(() {
        _showOrderProducts = newValue;
        fetchProductsFromDatabase();
      });
    }
  }

  Future<void> fetchProductsFromDatabase() async {
    List<Product> products = await dbHelper.getProducts();
    setState(() {
      _products = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOrderProducts) {
      _products = _products
          .where((product) => double.parse(product.order) > 0)
          .toList();
    } else {
      // fetchProductsFromDatabase();
    }

    if (_showOrderProducts!) {
      _products = _products.toList();
    }
    if (_sortByCompanyName) {
      _products.sort((a, b) {
        if (a.companyCode == b.companyCode) {
          return a.name.compareTo(b.name);
        } else {
          return a.companyCode.compareTo(b.companyCode);
        }
      });
    } else {
      _products.sort((a, b) {
        if (a.companyCode == b.companyCode) {
          return double.parse(b.order).compareTo(double.parse(a.order));
        } else {
          return a.companyCode.compareTo(b.companyCode);
        }
      });
    }
    // _products.sort((a, b) => a.name.compareTo(b.name));
    return WillPopScope(
      onWillPop: () async {
        if (_dataSent) {
          return true; // Allow back navigation if data is already sent
        } else {
          // Show an alert dialog or any other prompt to inform the user to send the data first
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Alert'),
                content:
                    Text('Please send the data before leaving this screen.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return false; // Prevent back navigation
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () async {
                bool confirmCancelOrder = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Cancel Order", textAlign: TextAlign.center),
                      content: Text("Do you want to cancel the order?"),
                      actions: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                    context, false); // User selected No
                              },
                              child: Text("No"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                    context, true); // User selected Yes
                              },
                              child: Text("Yes"),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        )
                      ],
                    );
                  },
                );
                if (confirmCancelOrder != null && confirmCancelOrder) {
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(
                Icons.cancel_outlined,
                color: Colors.red,
              )),
          actions: [
            Row(
              children: [
                Text('Show Selected'),
                Checkbox(
                  value: _showOrderProducts,
                  onChanged: _showOrderProduct,
                ),
              ],
            ),
            Row(
              children: [
                Text('Sort'),
                Checkbox(
                  value: _sortByCompanyName,
                  onChanged: _toggleSort,
                ),
              ],
            ),
            IconButton(
                onPressed: () async {
                  bool confirmCancelOrder = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Send Order", textAlign: TextAlign.center),
                        content: Text("Do you want to send the orders?"),
                        actions: [
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context, false); // User selected No
                                },
                                child: Text("No"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context, true); // User selected Yes
                                },
                                child: Text("Yes"),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          )
                        ],
                      );
                    },
                  );
                  if (confirmCancelOrder != null && confirmCancelOrder) {
                    await Utils.showLoaderDialog(
                        context, "Sending data to server", "Please wait...");
                    await fetchMaxPurOrderNo();
                    await fetchPurNo();
                    await sendDataToServer(_products);
                    await fetchOrdersDataAndStoreLocally();
                    _dataSent = true;
                    Navigator.pop(context);
                    if (_orders.isNotEmpty)
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyPdfWidget(
                              myData: MyData(
                                _orders,
                              ),
                              pageBack: true,
                            ),
                          ));
                    // Navigator.pop(context);
                    // Navigator.pop(context);
                    // Navigator.pop(context);
                    // Navigator.pop(context);
                  }
                },
                icon: Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ))
          ],
          title: Text('Product List'),
        ),
        body: _products.isNotEmpty
            ? Column(
                children: [
                  Card(
                    color: Colors.green.shade900,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 5, bottom: 5),
                      child: Container(
                        width: 500,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Bal: ',
                              style: TextStyle(
                                color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Req: ',
                              style: TextStyle(
                                color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Order: ',
                              style: TextStyle(
                                color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Rate: ',
                              style: TextStyle(
                                color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Disc: ',
                              style: TextStyle(
                                color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Amt: ',
                              style: TextStyle(
                                color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (BuildContext context, int index) {
                        final product = _products[index];
                        final double qty =
                            double.tryParse(product.qty.toString()) ?? 0.0;
                        final double rate =
                            double.tryParse(product.rate.toString()) ?? 0.0;
                        final double minOrder =
                            double.tryParse(product.minOrder.toString()) ?? 0.0;
                        final int unit =
                            int.tryParse(product.unit.toString()) ?? 0;
                        final double lBal = (unit > 0) ? (qty % unit) : 0;
                        final double pBal = (unit > 0) ? (qty / unit) : 0.0;
                        final double rates = unit * rate;
                        final double amt =
                            (double.parse(product.order) * rate) -
                                (double.parse(product.order) *
                                    rate *
                                    double.parse(product.dip) /
                                    100);
                        final bool isNewGroup = index == 0 ||
                            product.cname != _products[index - 1].cname;

                        return Column(
                          children: [
                            if (isNewGroup)
                              Card(
                                color: Colors.lightGreen.shade500,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 8),
                                  child: Text(
                                    product.cname,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: () {
                                print('hululu ${product.order}');
                                TextEditingController orderController =
                                TextEditingController(
                                    text: (double.parse(product.order) < 0 ? '0' : double.parse(product.order).toInt().toString()));
                                TextEditingController rateController =
                                TextEditingController(
                                    text: product.rate.toString());
                                TextEditingController discController =
                                TextEditingController(
                                    text: double.parse(product.dip)
                                        .toStringAsFixed(0));
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(product.name, textAlign: TextAlign.center,style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold
                                      ),),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(
                                            child: TextField(
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold
                                              ),
                                              controller:
                                              orderController,
                                              onTap: () => orderController
                                                  .selection =
                                                  TextSelection(
                                                      baseOffset: 0,
                                                      extentOffset:
                                                      orderController
                                                          .value
                                                          .text
                                                          .length),
                                              decoration:
                                              InputDecoration(
                                                  labelStyle: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                  labelText:
                                                  'Order'),
                                              keyboardType:
                                              TextInputType.number,
                                            ),
                                          ),
                                          TextField(
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold
                                            ),
                                            controller: rateController,
                                            onTap: () => rateController
                                                .selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                    rateController
                                                        .value
                                                        .text
                                                        .length),
                                            decoration: InputDecoration(
                                                labelStyle: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold
                                                ),
                                                labelText: 'Rate'),
                                            keyboardType:
                                            TextInputType.number,
                                          ),
                                          TextField(
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold
                                            ),
                                            controller: discController,
                                            onTap: () => discController
                                                .selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                    discController
                                                        .value
                                                        .text
                                                        .length),
                                            decoration: InputDecoration(
                                                labelStyle: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold
                                                ),
                                                labelText: 'Discount'),
                                            keyboardType:
                                            TextInputType.number,
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            double orders =
                                            double.parse(
                                                orderController
                                                    .text);
                                            double rate = double.parse(
                                                rateController.text);
                                            double disc = double.parse(
                                                discController.text);
                                            // Update product data
                                            product.order =
                                                orders.toString();
                                            product.rate =
                                                rate.toString();
                                            product.dip =
                                                disc.toString();
                                            // Update discount if needed

                                            // Update database
                                            await DBHelperProduct()
                                                .updateProduct(product);

                                            // Update the UI
                                            setState(() {});

                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Card(
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '   ${product.name}'
                                        // ' (${product.pCode})'
                                        '',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                     Row(
                                       children: [
                                         GestureDetector(
                                           onTap: () async {
                                             await _fetchPurData(product.pCode);
                                             showDialog(
                                               context: context,
                                               builder: (BuildContext context) {
                                                 return AlertDialog(
                                                   title:  Column(
                                                     children: [
                                                       Row(
                                                         children: [
                                                           Expanded(child: Card(
                                                             color: Colors.green.shade900,
                                                             child: Padding(
                                                               padding: const EdgeInsets.symmetric(
                                                                   vertical: 8.0, horizontal: 8),
                                                               child: Text(
                                                                 product.name,
                                                                 textAlign: TextAlign.center,
                                                                 style: TextStyle(
                                                                   fontSize: 16,
                                                                   color: Colors.white,
                                                                   fontWeight: FontWeight.bold,
                                                                 ),
                                                               ),
                                                             ),
                                                           ),)
                                                         ],
                                                       ),
                                                       SizedBox(
                                                         height: 10,
                                                       ),
                                                       Row(
                                                         mainAxisAlignment:
                                                         MainAxisAlignment
                                                             .spaceEvenly,
                                                         children: [
                                                           Text(
                                                             'Rate: ',
                                                             style: TextStyle(
                                                                         color: Colors.redAccent,
                                                                 fontSize: 16,
                                                                 fontWeight:
                                                                 FontWeight
                                                                     .bold),
                                                           ),
                                                           Text(
                                                             'Qty: ',
                                                             style: TextStyle(
                                                                         color: Colors.redAccent,
                                                                 fontSize: 16,
                                                                 fontWeight:
                                                                 FontWeight
                                                                     .bold),
                                                           ),
                                                           Text(
                                                             'Bonus: ',
                                                             style: TextStyle(
                                                                         color: Colors.redAccent,
                                                                 fontSize: 16,
                                                                 fontWeight:
                                                                 FontWeight
                                                                     .bold),
                                                           ),
                                                           Text(
                                                             'Dip1: ',
                                                             style: TextStyle(
                                                                         color: Colors.redAccent,
                                                                 fontSize: 16,
                                                                 fontWeight:
                                                                 FontWeight
                                                                     .bold),
                                                           ),
                                                           Text(
                                                             'Dip2: ',
                                                             style: TextStyle(
                                                                         color: Colors.redAccent,
                                                                 fontSize: 16,
                                                                 fontWeight:
                                                                 FontWeight
                                                                     .bold),
                                                           ),
                                                         ],
                                                       ),
                                                       Divider(
                                                         color: Colors.black,
                                                         thickness: 1,
                                                       ),
                                                     ],
                                                   ),
                                                   content: Container(
                                                     height: double.infinity,
                                                     width: double.maxFinite,
                                                     child: _purData.isNotEmpty
                                                         ? ListView.builder(
                                                       itemCount:
                                                       _purData.length,
                                                       itemBuilder:
                                                           (context, index) {
                                                         final pur =
                                                         _purData[index];
                                                         final double purUnit =
                                                             double.tryParse(product.unit.toString()) ?? 0.0;
                                                         final double purRate =
                                                             double.tryParse(pur.rate.toString()) ?? 0.0;
                                                         final double purQty =
                                                             double.tryParse(pur.qty.toString()) ?? 0.0;
                                                         final double qtys = (unit > 0) ? (purQty / purUnit) : 0;
                                                         final double rates = (unit > 0) ? (purRate * purUnit) : 0;
                                                         return Card(
                                                             child: Column(
                                                               children: [
                                                                 Row(
                                                                   mainAxisAlignment:
                                                                   MainAxisAlignment
                                                                       .spaceEvenly,
                                                                   children: [
                                                                     Text(rates.toStringAsFixed(2),
                                                                       style: TextStyle(
                                                                         color: Colors.redAccent,
                                                                           fontWeight:
                                                                           FontWeight.bold),),
                                                                     Text(qtys.toStringAsFixed(0),
                                                                       style: TextStyle(
                                                                           color: Colors.redAccent,
                                                                           fontWeight:
                                                                           FontWeight.bold),),
                                                                     Text(pur
                                                                         .bonus,
                                                                       style: TextStyle(
                                                                           color: Colors.redAccent,
                                                                           fontWeight:
                                                                           FontWeight.bold),),
                                                                     Text(
                                                                         pur.dip1,
                                                                       style: TextStyle(
                                                                           color: Colors.redAccent,
                                                                           fontWeight:
                                                                           FontWeight.bold),),
                                                                     Text(
                                                                         pur.dip2,
                                                                       style: TextStyle(
                                                                           color: Colors.redAccent,
                                                                           fontWeight:
                                                                           FontWeight.bold),),
                                                                   ],
                                                                 ),

                                                                 Divider(
                                                                   color: Colors.black,
                                                                 ),
                                                                 Row(
                                                                   mainAxisAlignment:
                                                                   MainAxisAlignment
                                                                       .spaceEvenly,
                                                                   children: [
                                                                     Row(
                                                                       children: [
                                                                         Text(
                                                                           'Inv No :',
                                                                           style: TextStyle(
                                                                               fontWeight:
                                                                               FontWeight.bold),
                                                                         ),
                                                                         Text(
                                                                             '${pur.invno}  ',
                                                                           style: TextStyle(
                                                                               fontWeight:
                                                                               FontWeight.bold),),
                                                                       ],
                                                                     ),
                                                                     Text(
                                                                       'Date :',
                                                                       style: TextStyle(
                                                                           fontWeight:
                                                                           FontWeight.bold),
                                                                     ),
                                                                     Text(
                                                                         '${pur.invdt}',
                                                                       style: TextStyle(
                                                                           fontWeight:
                                                                           FontWeight.bold),),
                                                                   ],
                                                                 ),
                                                                 Row(
                                                                   mainAxisAlignment:
                                                                   MainAxisAlignment
                                                                       .spaceEvenly,
                                                                   children: [
                                                                     Row(
                                                                       children: [
                                                                         Text(
                                                                           'Batch No :',
                                                                           style: TextStyle(
                                                                               fontWeight:
                                                                               FontWeight.bold),
                                                                         ),
                                                                         Text(
                                                                             '${pur.batchNo}  ',
                                                                           style: TextStyle(
                                                                               fontWeight:
                                                                               FontWeight.bold),),
                                                                       ],
                                                                     ),
                                                                     Text(
                                                                       'Expdt :',
                                                                       style: TextStyle(
                                                                           fontWeight:
                                                                           FontWeight.bold),
                                                                     ),
                                                                     Text(
                                                                         '${pur.expdt}',
                                                                       style: TextStyle(
                                                                           fontWeight:
                                                                           FontWeight.bold),),
                                                                   ],
                                                                 ),

                                                                 Row(
                                                                   mainAxisAlignment:
                                                                   MainAxisAlignment
                                                                       .center,
                                                                   children: [
                                                                     Text(
                                                                       '${pur.name}',
                                                                       style:
                                                                       TextStyle(
                                                                         fontWeight:
                                                                         FontWeight
                                                                             .bold,
                                                                       ),
                                                                     ),
                                                                   ],
                                                                 ),
                                                               ],
                                                             ));
                                                       },
                                                     )
                                                         : Center(
                                                         child: Text('No Data')),
                                                   ),
                                                   actions: [
                                                     Center(
                                                       child: ElevatedButton(
                                                         child: Text('Close'),
                                                         onPressed: () {
                                                           Navigator.of(context)
                                                               .pop();
                                                         },
                                                       ),
                                                     )
                                                   ],
                                                 );
                                               },
                                             );
                                           },
                                           child: Text(
                                             'Pur   ',
                                             textAlign: TextAlign.center,
                                             style: TextStyle(
                                               backgroundColor:
                                               Colors.green.shade900,
                                               color: Colors.white,
                                               fontSize: 18,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                         ),
                                         GestureDetector(
                                           onTap: () async {
                                             await _fetchSalesData(product.pCode);
                                             showDialog(
                                               context: context,
                                               builder: (BuildContext context) {
                                                 return AlertDialog(
                                                   title:  Column(
                                                     children: [
                                                       Row(
                                                         children: [
                                                           Expanded(child: Card(
                                                             color: Colors.green.shade900,
                                                             child: Padding(
                                                               padding: const EdgeInsets.symmetric(
                                                                   vertical: 8.0, horizontal: 8),
                                                               child: Text(
                                                                 product.name,
                                                                 textAlign: TextAlign.center,
                                                                 style: TextStyle(
                                                                   fontSize: 16,
                                                                   color: Colors.white,
                                                                   fontWeight: FontWeight.bold,
                                                                 ),
                                                               ),
                                                             ),
                                                           ),)
                                                         ],
                                                         mainAxisAlignment: MainAxisAlignment.center,
                                                       ),
                                                       SizedBox(
                                                         height: 5,
                                                       ),
                                                       Row(
                                                         mainAxisAlignment:
                                                         MainAxisAlignment
                                                             .spaceEvenly,
                                                         children: [
                                                           Text(
                                                             'Month',
                                                             style: TextStyle(
                                                                 fontWeight:
                                                                 FontWeight.bold,
                                                                 fontSize: 24),
                                                           ),
                                                           Text(
                                                             'Sale',
                                                             style: TextStyle(
                                                                 fontWeight:
                                                                 FontWeight.bold,
                                                                 fontSize: 24),
                                                           ),
                                                         ],
                                                       ),
                                                       Divider(
                                                         color: Colors.black,
                                                         thickness: 1,
                                                       ),
                                                     ],
                                                   ),
                                                   content: Container(
                                                     height: 250,
                                                     // Adjust the height according to your requirement
                                                     width: double.maxFinite,
                                                     child: _salesData.isNotEmpty
                                                         ? ListView.builder(
                                                       itemCount:
                                                       _salesData.length,
                                                       itemBuilder:
                                                           (context, index) {
                                                         final sale =
                                                         _salesData[index];
                                                         final double qtys =
                                                             double.tryParse(sale.totalQty) ?? 0.0;
                                                         final double lBals = (qtys % unit);
                                                         final double pBals = (qtys / unit);
                                                         return Card(
                                                           child: ListTile(
                                                               title: Row(
                                                                 mainAxisAlignment:
                                                                 MainAxisAlignment
                                                                     .spaceEvenly,
                                                                 children: [
                                                                   Text(
                                                                       '${sale.month}, ${sale.year}' , style: TextStyle(
                                                                     fontWeight: FontWeight.bold,
                                                                      fontSize: 18
                                                                   ),),
                                                                   Text('${pBals.toInt()}-${lBals.toInt()}' , style: TextStyle(
                                                                     fontWeight: FontWeight.bold,
                                                                       fontSize: 18
                                                                   ),)
                                                                 ],
                                                               )),
                                                         );
                                                       },
                                                     )
                                                         : Center(
                                                         child: Text('No Data')),
                                                   ),
                                                   actions: [
                                                     Center(
                                                       child: ElevatedButton(
                                                         child: Text('Close'),
                                                         onPressed: () {
                                                           Navigator.of(context)
                                                               .pop();
                                                         },
                                                       ),
                                                     )
                                                   ],
                                                 );
                                               },
                                             );
                                           },
                                           child: Text(
                                             'Sale   ',
                                             textAlign: TextAlign.center,
                                             style: TextStyle(
                                               backgroundColor: Colors.redAccent,
                                               color: Colors.white,
                                               fontSize: 18,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                         ),
                                       ],
                                     )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        '${pBal.toInt()}-${lBal.toInt()}',
                                        style: TextStyle(
                                            color:
                                                double.parse(product.order) <= 0
                                                    ? Colors.lightGreen.shade500
                                                    : Colors.red,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${product.minOrder}',
                                        style: TextStyle(
                                            color:
                                                double.parse(product.order) <= 0
                                                    ? Colors.lightGreen.shade500
                                                    : Colors.red,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      double.parse(product.order).toInt() < 0
                                          ? Text(
                                              '0',
                                              style: TextStyle(
                                                backgroundColor: double.parse(
                                                    product.order).toInt() <=
                                                    0
                                                    ? Colors
                                                    .lightGreen.shade500
                                                    : Colors.red,
                                                  color: Colors.white,
                                                  fontSize: double.parse(
                                                              product.order).toInt() <=
                                                          0
                                                      ? 18
                                                      : 24,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Text(
                                              '${double.parse(product.order).toInt()}',
                                              style: TextStyle(
                                                backgroundColor:  double.parse(
                                                    product.order).toInt() <=
                                                    0
                                                    ? Colors
                                                    .lightGreen.shade500
                                                    : Colors.red,
                                                  color:Colors.white,
                                                  fontSize: double.parse(
                                                              product.order).toInt() <=
                                                          0
                                                      ? 18
                                                      : 24,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                      Text(
                                        '${product.rate}',
                                        style: TextStyle(
                                            color:
                                                double.parse(product.order) <= 0
                                                    ? Colors.lightGreen.shade500
                                                    : Colors.red,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${double.parse(product.dip).toStringAsFixed(2)}',
                                        style: TextStyle(
                                            color:
                                                double.parse(product.order) <= 0
                                                    ? Colors.lightGreen.shade500
                                                    : Colors.red,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      double.parse(product.order) < 0
                                          ? Text(
                                              '0',
                                              style: TextStyle(
                                                  color: double.parse(
                                                              product.order) <=
                                                          0
                                                      ? Colors.lightGreen.shade500
                                                      : Colors.red,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Text(
                                              '${amt.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                  color: double.parse(
                                                              product.order) <=
                                                          0
                                                      ? Colors.lightGreen.shade500
                                                      : Colors.red,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                    ],
                                  ),
                                ]),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator()),
        bottomNavigationBar: Card(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
            child: _products.isEmpty
                ? null // Show circular progress indicator if loading or order data is empty
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grand Total :',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rs. ${calculateAmt().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => MyPdfWidget(myData: MyData(
        //     _products,
        //   ),),));
        // },
        // child: Icon(Icons.print),
        // ),
      ),
    );
  }

  Future<void> _printDocument(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Cash Memo'),
            ),
            pw.Table.fromTextArray(
              headers: ['Product Name', 'Rate', 'Discount', 'Amount'],
              data: _products
                  .map((item) => [
                        item.name,
                        '${item.rate}',
                        '${item.dip}%',
                        '${item.order}'
                      ])
                  .toList(),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/cash_memo.pdf');
    await file.writeAsBytes(await pdf.save());
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    // Open the generated PDF document using open_document package
  }
}
