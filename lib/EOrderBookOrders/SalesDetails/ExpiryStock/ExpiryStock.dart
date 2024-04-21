import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CashIn.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CashOut.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/CompanyWise.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/DistributorWise.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/ExpiryStock/DistributorWise/ExpiryDistributorWise.dart';
import 'package:eorderbook/EOrderBookOrders/SalesDetails/ProductWise.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'CompanyWise/ExpiryCompanyWise.dart';
import 'ProductWise/ExpiryProductWise.dart';

class ExpiryStock extends StatefulWidget {
  final String mainCode;
  final String distCode;
  final String days;
  final String startDate;
  final String endDate;

  ExpiryStock({
    required this.mainCode,
    required this.distCode,
    required this.days,
    required this.startDate,
    required this.endDate,
  });

  @override
  _ExpiryStockState createState() => _ExpiryStockState();
}

class _ExpiryStockState extends State<ExpiryStock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Expiry Stock',
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
                      builder: (context) => ExpiryProductWIse(
                        days: widget.days,
                          mainCode: widget.mainCode,
                          distCode: widget.distCode,),
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
                      builder: (context) => ExpiryCompanyWIse(
                        days: widget.days,
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
                      builder: (context) => ExpiryDistributorWIse(
                        days: widget.days,
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
