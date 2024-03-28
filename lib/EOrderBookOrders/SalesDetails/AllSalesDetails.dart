import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AllSalesDetails extends StatefulWidget {
  final String mainCode;
  final String startDate;
  final String endDate;
  AllSalesDetails({required this.mainCode, required this.startDate, required this.endDate});

  @override
  _AllSalesDetailsState createState() => _AllSalesDetailsState();
}

class _AllSalesDetailsState extends State<AllSalesDetails> {


  List<dynamic> invoices = [];
  void initState(){
    super.initState();
    fetchInvoices(widget.mainCode, widget.startDate, widget.endDate);
  }

  Future<void> fetchInvoices(String mainCode, String startDate, String endDate) async {
    final url = Uri.parse('https://seasoftsales.com/eorderbook/get_allinv.php?main_code=$mainCode&start_date=$startDate&end_date=$endDate');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          invoices = responseData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }




  @override
  Widget build(BuildContext context) {

    var invoiced = invoices.isNotEmpty ? invoices.first : null;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:Text('${invoiced['main_name']}',style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
        ),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: invoices.length,
                itemBuilder: (BuildContext context, int index) {
                  final invoice = invoices[index];
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
                            Text('Dist Name : ${invoice['dist_name']}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),),
                            Text("Net Amount : ${invoice['net']}     Main Code : ${invoice['main_code']}",
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                  // return ListTile(
                  //   title: Text('Main Name: ${invoice['main_name']}'),
                  //   subtitle: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text('Total Invoice: ${invoice['total_invoice']}'),
                  //       Text('Net: ${invoice['net']}'),
                  //       Text('Sale Return: ${invoice['sale_return']}'),
                  //       Text('Cash: ${invoice['cash']}'),
                  //       Text('Dist Code: ${invoice['dist_code']}'),
                  //       Text('Main Code: ${invoice['main_code']}'),
                  //       Text('Dist Name: ${invoice['dist_name']}'),
                  //     ],
                  //   ),
                  // );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
