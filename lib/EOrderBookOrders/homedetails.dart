import 'package:eorderbook/EOrderBookOrders/OrderDetailLogin/orderdetailbylogin.dart';
import 'package:eorderbook/EOrderBookOrders/OrderDetailLogin/ordermapsbylogin.dart';
import 'package:eorderbook/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeDetails extends StatefulWidget {
  const HomeDetails({super.key});

  @override
  State<HomeDetails> createState() => _HomeDetailsState();
}

class _HomeDetailsState extends State<HomeDetails> {
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
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
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
        title: Text('EOrderBook Details'),

        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            Text('Select the following' , style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 100 , left: 100 , bottom: 20),
              child: ElevatedButton(onPressed: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsLogin(),));
              }, child: Row(
                children: [
                  Icon(Icons.route),
                  SizedBox(
                    width: 20,
                  ),
                  Text('List View',style: TextStyle(
                    fontSize: 24
                  ),)
                ],
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 100 , left: 100 ,),
              child: ElevatedButton(
                  onPressed: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => OrderMapLogin(),));
              }, child: Row(
                children: [
                  Icon(Icons.map),
                  SizedBox(
                    width: 20,
                  ),
                  Text('Map View',style: TextStyle(
                    fontSize: 24
                  ),)
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
