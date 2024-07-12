import 'package:eorderbook/EOrderBookOrders/OrderLoginHome.dart';
import 'package:eorderbook/EOrderBookOrders/homedetails.dart';
import 'package:eorderbook/EOrderBookOrders/OrderDetailLogin/orderdetailbylogin.dart';
import 'package:eorderbook/screens/invoice_list_screen.dart';
import 'package:eorderbook/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'EOrderBookOrders/SalesDetails/SalesDetails.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if the user is already logged in
  var prefs = await SharedPreferences.getInstance();
  var isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  const MyApp({required this.isLoggedIn, super.key});

  final bool isLoggedIn;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  void initState(){
    super.initState();
    _getPermission();
  }

  bool _permission = false;

  void _getPermission() async {
    final grant = await Permission.location.request().isGranted;
    setState(() {
      _permission = grant;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Or any other loading indicator
          }
          final prefs = snapshot.data!;
          final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

          if (isLoggedIn) {
            final eorderbookuser = prefs.getInt('eorderbookuser') ?? 0;
            if(eorderbookuser == 0){
              return LoginScreen();
            }
            else if(eorderbookuser == 1){
              return InvoiceListScreen();
            }else if (eorderbookuser == 2) {
              return SalesDetails();
            }else if (eorderbookuser == 3) {
              return OrderDetailsLogin();
            } else {
              // Handle other cases if needed
              return Container(); // Placeholder, replace with appropriate widget
            }
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }

}


// Column(
// children: [
// SingleChildScrollView(
// scrollDirection: Axis.horizontal,
// child: Text(widget.customer.name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
// Text('${widget.area.name}  (Total : ${totalPrice})', style: TextStyle(
// fontSize: 16
// ),)
// ],
// ),


// Row(
// children: [
// Checkbox(
// value: showSelected,
// onChanged: (value) {
// setState(() {
// showSelected = value!;
// });
// }),
// const Text("Show Selected Product"),
//
// ],
// ),
//
//
//
// CheckboxListTile(
// title: Text('Show positive balance only'),
// value: showPositiveBalanceOnly,
// onChanged: (value) {
// setState(() {
// showPositiveBalanceOnly = value!;
// });
// },
// ),


// Column(
// mainAxisSize: MainAxisSize.min,
// children: [
// CheckboxListTile(
// title: Text('Show Selected Product'),
// value: showSelected,
// onChanged: (value) {
// setState(() {
// showSelected = value!;
// });
// },
// ),
// CheckboxListTile(
// title: Text('Show positive balance only'),
// value: showPositiveBalanceOnly,
// onChanged: (value) {
// setState(() {
// showPositiveBalanceOnly = value!;
// });
// },
// ),
//
// ],
// ),`