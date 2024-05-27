import 'dart:convert';
import 'package:eorderbook/EOrderBookOrders/Alerts/ModifiedBills/ModifiedSaleBills/ModifiedBills.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ModifiedBillsHome extends StatefulWidget {
  final String distCode;
  final String startDate;
  final String endDate;

  const ModifiedBillsHome({
    required this.distCode,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ModifiedBillsHome> createState() => _ModifiedBillsHomeState();
}

class _ModifiedBillsHomeState extends State<ModifiedBillsHome> {
  Map<String, dynamic> profitinvoices = {};
  Map<String, dynamic> profitinvoices1 = {};
  Map<String, dynamic> profitinvoices2 = {};

  @override
  void initState() {
    super.initState();
    fetchProfit();
    fetchProfit1();
    fetchProfit2();
  }

  Future<void> fetchProfit() async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_modified_invoice_nos.php?type=33&start_date=${widget.startDate}&dist_code=${widget.distCode}&end_date=${widget.endDate}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);  // Log the response body
        if (responseData is Map<String, dynamic>) {
          setState(() {
            profitinvoices = responseData;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> fetchProfit1() async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_modified_invoice_nos.php?type=444&start_date=${widget.startDate}&dist_code=${widget.distCode}&end_date=${widget.endDate}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);  // Log the response body
        if (responseData is Map<String, dynamic>) {
          setState(() {
            profitinvoices1 = responseData;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> fetchProfit2() async {
    final url = Uri.parse(
        'https://seasoftsales.com/eorderbook/get_modified_invoice_nos.php?type=1&start_date=${widget.startDate}&dist_code=${widget.distCode}&end_date=${widget.endDate}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);  // Log the response body
        if (responseData is Map<String, dynamic>) {
          setState(() {
            profitinvoices2 = responseData;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load data');
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
        title: Text(
          'Alerts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ModifiedBills(distCode: widget.distCode, type: '33', startDate: widget.startDate, endDate: widget.endDate),));
              },
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        'Modified Sale Bills',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        '${profitinvoices['total_invoices'] ?? '0'}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ModifiedBills(distCode: widget.distCode, type: '444', startDate: widget.startDate, endDate: widget.endDate),));
              },
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        'Modified Sale Return Bills',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        '${profitinvoices1['total_invoices'] ?? '0'}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ModifiedBills(distCode: widget.distCode, type: '1', startDate: widget.startDate, endDate: widget.endDate),));
              },
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        'Modified Purchase Bills',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        '${profitinvoices2['total_invoices'] ?? '0'}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
