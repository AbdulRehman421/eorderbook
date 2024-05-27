import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/Inovice/InvoiceData.dart';
import 'package:eorderbook/EOrderBookOrders/Inovice/invoice.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/Purchase%20Order%20Print/InvoiceDataNew.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/Purchase%20Order%20Print/invoiceNew.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../Model/OrderModel.dart';
import '../Model/OrderModelNew.dart';
import 'PurchasePrintModel.dart';

class PurchaseOrderPrint extends StatefulWidget {
  final String distCode;

  const PurchaseOrderPrint({
    required this.distCode,
    super.key});

  @override
  State<PurchaseOrderPrint> createState() => _PurchaseOrderPrintState();
}

class _PurchaseOrderPrintState extends State<PurchaseOrderPrint> {
  List<PurchasePrintModel> _purOrder = [];
  List<Order> _orders = [];
  List<OrderNew> _ordersNew = [];

  void initState() {
    super.initState();
    _fetchPurOrder();
  }
  Future<void> fetchOrdersData(String orderId) async {
    final response = await http.get(Uri.parse(
        'https://seasoftsales.com/eorderbook/get_pur_order_detail.php?dist_code=${widget.distCode}&order_id=$orderId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _orders = data.map((item) => Order.fromJson(item)).toList();
        _ordersNew = data.map((item) => OrderNew.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> _fetchPurOrder() async {
    try {
      final response = await http.get(Uri.parse('https://seasoftsales.com/eorderbook/get_pur_order.php?dist_code=${widget.distCode}'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<PurchasePrintModel> purData = responseData.map((data) => PurchasePrintModel.fromJson(data)).toList();
        setState(() {
          _purOrder = purData;
        });
      } else {
        throw Exception('Failed to load product Purchase sale data');
      }
    } catch (e) {
      print('Error fetching Purchase sales data: $e');
      // Handle error
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Order Print'),
      ),
      body: Column(
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
                      'Order Id: ',
                      style: TextStyle(
                                          color: Colors.white,
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Order No: ',
                      style: TextStyle(
                                          color: Colors.white,
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Date: ',
                      style: TextStyle(
                                          color: Colors.white,
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Amount: ',
                      style: TextStyle(
                                          color: Colors.white,
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _purOrder.isNotEmpty
              ? Expanded(
                child: ListView.builder(
                            itemCount: _purOrder.length,
                            itemBuilder: (context, index) {
                final sale = _purOrder[index];
                final double amount = double.parse(sale.amount);
                return Card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('   ${sale.name}',style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('${sale.purNo}      ',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),),
                          Text(sale.dPurNo,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),),
                          Text(sale.date,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),),
                          Text(amount.toStringAsFixed(2),
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),),
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text('   Amount' ,style: TextStyle(
                      //       fontWeight: FontWeight.bold
                      //     ),),
                      //     Text('${amount.toStringAsFixed(2)}   ',
                      //       style: TextStyle(fontWeight: FontWeight.bold),)
                      //   ],
                      // )
                      Row(
                        children: [
                          ElevatedButton(
                          onPressed: () async {
                              await fetchOrdersData(sale.purNo);
                              if(_orders.isNotEmpty)
                              await Navigator.push(context, MaterialPageRoute(builder: (context) => MyPdfWidget(myData: MyData(
                              _orders,
                              ), pageBack: false,),));
                              }, child: Text('Format 1')),
                          ElevatedButton(
                          onPressed: () async {
                              await fetchOrdersData(sale.purNo);
                              if(_ordersNew.isNotEmpty)
                              await Navigator.push(context, MaterialPageRoute(builder: (context) => MyPdfWidgetNew(myData: MyDataNew(
                              _ordersNew,
                              ), pageBack: false,),));
                              },

                              child: Text('Format 2')),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      )
                    ],
                  )
                );
                            },
                          ),
              )
              : Center(child: Text('No Data')),
        ],
      ),

    );
  }
}
