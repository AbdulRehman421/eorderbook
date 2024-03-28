import 'package:eorderbook/EOrderBookOrders/SalesDetails/SalesDetails.dart';
import 'package:eorderbook/EOrderBookOrders/OrderDetailLogin/orderdetailbylogin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/login_screen.dart';

class OrderLoginHome extends StatefulWidget {
  const OrderLoginHome({super.key});

  @override
  State<OrderLoginHome> createState() => _OrderLoginHomeState();
}

class _OrderLoginHomeState extends State<OrderLoginHome> {

  Future<bool> showLogoutDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout Confirmation"),
          content: const Text("Are you sure to logout from this account?"),
          actions: <Widget>[
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("YES"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              bool confirmDelete = await showLogoutDialog(context);
              if (confirmDelete) {
                SharedPreferences s = await SharedPreferences.getInstance();
                s.clear();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                        (route) => false);
              } else {
                // Cancel delete action
              }
            },
            icon: const Icon(
              Icons.logout,
            )),

      centerTitle: true,
        title: Text('E-OrderBook'),
      ),
       body: Center(
         child: Column(
           children: [
             SizedBox(
               height: 10,
             ),
             GestureDetector(
               onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsLogin()));

               },
               child: Card(
                 child: Container(
                   child:Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text('Order Details'),
                   ),
                 ),
               ),
             ),
             SizedBox(height: 50,),
             GestureDetector(
               onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => SalesDetails()));

               },
               child: Card(
                 child: Container(
                   child:Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text('Sales Details'),
                   ),
                 ),
               ),
             )
           ],
         ),
       ),
    );
  }
}
