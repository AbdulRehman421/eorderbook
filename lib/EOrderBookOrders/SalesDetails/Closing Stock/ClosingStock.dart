import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CashIn.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CashOut.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CheckProductOnBranches.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/PharmacyWise/pharmacywise.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/Closing%20Stock/Purchase%20Order%20Print/PurchaseOrderPrint.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CompanyWise.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/DistributorWise.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/ProductWise.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Purchase Order/PurchaseOrderDistributor.dart';

class ClosingStock extends StatefulWidget {
  final String mainCode;
  final String distCode;
  final String startDate;
  final String endDate;

  ClosingStock({
    required this.mainCode,
    required this.distCode,
    required this.startDate,
    required this.endDate,
  });

  @override
  _ClosingStockState createState() => _ClosingStockState();
}

class _ClosingStockState extends State<ClosingStock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Stock Position',
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
                      builder: (context) => ProductWIse(
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
                    'Product Wise ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
                      builder: (context) => CompanyWIse(
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
                    'Company Wise',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
                      builder: (context) => DistributorWIse(
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
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckProductOnBranches(
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
                    'Check Product on All Branches',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
                      builder: (context) => PharmacyWise(
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
                    'Purchase Order ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            // SizedBox(
            //   height: 20,
            // ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => PurchaseOrderDistributor(
            //               mainCode: widget.mainCode,
            //               distCode: widget.distCode,
            //               startDate: widget.startDate,
            //               endDate: widget.endDate),
            //         ));
            //   },
            //   child: Card(
            //     child: Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            //       child: Text(
            //         'Purchase Order',
            //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PurchaseOrderPrint(
                          distCode: widget.distCode,),
                    ));
              },
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Text(
                    'Purchase Order Print',
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
