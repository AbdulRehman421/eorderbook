import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/OrderDetailLogin/AllOrderDetailsLogin.dart';
import 'package:eorderbook/EOrderBookOrders/OrderDetailLogin/ordermapsbylogin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OrderDetailsScreenLogin extends StatefulWidget {
  final String distCode;
  final String userName;
  final DateTime selectedDate;

  const OrderDetailsScreenLogin({
    Key? key,
    required this.distCode,
    required this.userName,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreenLogin> {
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

    String apiUrl = 'https://seasoftsales.com/eorderbook/get_orders.php?dist_code=${widget.distCode}&user_name=${widget.userName}&selected_date=${widget.selectedDate}';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Column(
          children: [
            Text('Order Details (${orderData.length})'),
            Text('(${widget.selectedDate.day}-${widget.selectedDate.month}-${widget.selectedDate.year})',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isLoading && orderData.isNotEmpty)
            Center(
                child: Text('Order Amount : ${calculateTotalOrderAmount().toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                )
            ),
          SizedBox(
            height: 10,
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (!isLoading && orderData.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: orderData.length,
                itemBuilder: (context, index) {
                  orderData.sort((a, b) => a['date'].compareTo(b['date']));
                  var item = orderData[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AllOrderDetailsLogin(distCode: widget.distCode, order_id: item['order_id']),));
                    },
                    child: Card(
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
                              Text(item['name'],style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                              Text('${item['areaname']}  (${item['order_amount']})'),
                            ],
                          )
                        ],
                      ),
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
      floatingActionButton: Visibility(
        visible: !isLoading && orderData.isNotEmpty,
        child: FloatingActionButton.extended(
          onPressed: () async {
            Navigator.push(context, MaterialPageRoute(builder: (context) => OrderMapLogin(distcode: widget.distCode, username: widget.userName, selectedDates: widget.selectedDate),));
          },
          label: Text('Map View'),
        ),
      ),
    );
  }
}
