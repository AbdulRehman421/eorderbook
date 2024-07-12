import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CashIn.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CashOut.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CheckProductOnBranches.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/PharmacyWise/pharmacycompanywise.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/Purchase%20Order%20Print/PurchaseOrderPrint.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CompanyWise.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/DistributorWise.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/ProductWise.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Purchase Order/PurchaseOrderDistributor.dart';


class PharmacyWise extends StatefulWidget {
  final String mainCode;
  final String distCode;
  final String startDate;
  final String endDate;

  PharmacyWise({
    required this.mainCode,
    required this.distCode,
    required this.startDate,
    required this.endDate,
  });

  @override
  _PharmacyWiseState createState() => _PharmacyWiseState();
}

class _PharmacyWiseState extends State<PharmacyWise> {
  int _customValue = 0;
  Future<void> _openDialog() async {
    int? newValue = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int? enteredValue;
        return AlertDialog(
          title: Center(child: Text('Enter Order')),
          content: TextField(
            decoration: InputDecoration(

              hintText: '${_customValue}',
            ),
            autofocus: true,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              enteredValue = int.tryParse(value);
            },
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(enteredValue);
                },
                child: Text('OK'),
              ),
            ),
          ],
        );
      },
    );

    if (newValue != null && newValue != _customValue) {
      setState(() {
        _customValue = newValue!;
      });

      // Execute fetchStock(widget.distCode) here
      // fetchStock(widget.distCode);
      // fetchProfit3();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Purchase Order',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PharmacyCompanyWise(
                        order: _customValue.toString(),
                          mainCode: widget.mainCode,
                          distCode: widget.distCode,
                          startDate: widget.startDate,
                          endDate: widget.endDate),
                    ));
              },
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        'Order All Stock >',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    InkWell(
                      child: Row(
                        children: [
                          Text('$_customValue      ',
                            style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),),
                        ],
                      ),
                      onTap: () {
                        _openDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PurchaseOrderDistributor(
                          mainCode: widget.mainCode,
                          distCode: widget.distCode,
                          startDate: widget.startDate,
                          endDate: widget.endDate),
                    ));
              },
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Text(
                    'Distributor Wise',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
