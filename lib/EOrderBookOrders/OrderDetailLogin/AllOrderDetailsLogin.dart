import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AllOrderDetailsLogin extends StatefulWidget {
  final String distCode;
  final String order_id;


  const AllOrderDetailsLogin({
    Key? key,
    required this.distCode,
    required this.order_id,
  }) : super(key: key);

  @override
  _AllOrderDetailsLoginState createState() => _AllOrderDetailsLoginState();
}

class _AllOrderDetailsLoginState extends State<AllOrderDetailsLogin> {
  List<dynamic> orderData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    String apiUrl = 'https://seasoftsales.com/eorderbook/get_order_detail.php?dist_code=${widget.distCode}&order_id=${widget.order_id}';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        orderData = data;
      });
    } else {
      // Show a toast for the error
      Fluttertoast.showToast(
        msg: 'Failed to load data. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    setState(() {
      isLoading = false;
    });
  }
  double calculateTotalOrderAmount() {
    double totalAmount = 0.0;

    for (var item in orderData) {
      totalAmount += double.parse(item['order_amount']);
    }

    return totalAmount;
  }
  double calculateAmount(Map<String, dynamic> item) {
    double rate = double.parse(item['rate']);
    int qty = int.parse(item['qty']);
    double discountPercentage = double.parse(item['discount']);

    // Calculate discount amount
    double discountAmount = (rate * qty * discountPercentage / 100);

    // Calculate amount after discount
    double amount = (rate * qty) - discountAmount;
    return amount;
  }

  @override
  Widget build(BuildContext context) {
    var firstItem = orderData.isNotEmpty ? orderData.first : null;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text('Order Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (!isLoading && orderData.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.only(left: 20 , right: 20 , top: 20 , bottom: 20),
                child: Container(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Party Name :',style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                          Flexible(child: Text(firstItem['name'],
                            overflow: TextOverflow.ellipsis, // Handle overflow
                            maxLines: 1,))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Address :',style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                          Flexible(
                            child: Text(
                              firstItem['address'],
                              overflow: TextOverflow.ellipsis, // Handle overflow
                              maxLines: 1, // Limit to a single line
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Area :',style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                          Text(firstItem['areaname'])
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Date :',style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                          Text(firstItem['date'])
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order No :',style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                          Text(firstItem['order_id'])
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Remarks :',style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                          Text(firstItem['remarks'] ?? "No Remarks" )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!isLoading && orderData.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: orderData.length,
              itemBuilder: (context, index) {
                orderData.sort((a, b) => a['date'].compareTo(b['date']));
                var item = orderData[index];
                return Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text('${index + 1}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item['productname']}  (${item['pcode']})',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                          Row(
                            children: [
                              Text('Rate: ${item['rate']}  Qty:  ${item['qty']}  Bns:  ${item['bonus']}  Dis%  ${item['discount']}  Amt:  ${calculateAmount(item)}',style: TextStyle(
                                  fontSize: 12
                              ),)
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          if (!isLoading && orderData.isEmpty)
            Center(
              heightFactor: 2,
              child: Lottie.asset(kIsWeb
                  ? 'not_found_data.json'
                  : 'assets/not_found_data.json'),
            ),
        ],
      ),
        bottomNavigationBar: Card(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
            child: isLoading == true || orderData.isEmpty
                ? null // Show circular progress indicator if loading or order data is empty
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orders Amount :',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rs. ${firstItem['order_amount']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        )
      
    );
  }
}
