// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:path/path.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';
// import '../models/account.dart';
// import 'package:eorderbook/utils/Utils.dart';
// import 'package:eorderbook/widgets/ConstantWidget.dart';
// import 'package:path/path.dart' as path;
// import '../models/area.dart';
// import '../models/eorderbook_master.dart';
// import '../models/sector.dart';
// import '../services/db_helper.dart';
// import 'ProductAutoComplete.dart';
// import 'invoice_list_screen.dart';
//
// class CustomerAutoComplete extends StatefulWidget {
//   final Area areaId;
//   final Sector sectorId;
//
//   const CustomerAutoComplete(
//       {Key? key,
//         required this.areaId, required this.sectorId})
//       : super(key: key);
//   @override
//   itemsAutoCompleteState createState() => itemsAutoCompleteState();
// }
//
// class itemsAutoCompleteState extends State<CustomerAutoComplete> {
//   bool isButtonVisible = true;
//   bool visibility = true;
//   TextEditingController _controller = TextEditingController();
//   List<Account> allItems = []; // List to hold all items
//   List<Account> filteredItems = []; // List to hold filtered items
//   bool _isSearching = false;
//   late DatabaseHelper _databaseHelper;
//   @override
//   void initState() {
//     super.initState();
//     _databaseHelper = DatabaseHelper.instance;
//     getCheckLicExpDateFromSharedPreferences();
//     _loadItems();
//   }
//
//   Future<void> _loadItems() async {
//     // Load all items from the database
//     List<Account> allProducts = await _databaseHelper.getAccounts();
//     setState(() {
//       allItems = allProducts;
//       filteredItems = allProducts;
//     });
//   }
//
//   Future<bool> _invoiceData(Account customer) async {
//     final path = join(await getDatabasesPath(), 'eOrderBook.db');
//     Database database = await openDatabase(path);
//     String query =
//         'SELECT COUNT(*) FROM eorderbook_master WHERE code = ${customer.code}';
//
//     List<Map<String, dynamic>> result = await database.rawQuery(query);
//     int count = Sqflite.firstIntValue(result) ?? 0;
//
//     database.close();
//
//     if (count > 0) {
//       return true;
//     } else {
//       return false;
//     }
//   }
//
//   String checkLicExpDate = '';
//
//   Future<void> getCheckLicExpDateFromSharedPreferences() async {
//     // Retrieve check_lic_expdate value from shared preferences
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       // Update the state variable with the retrieved value
//       checkLicExpDate = prefs.getString('check_lic_expdate') ?? '';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           centerTitle: true,
//           title: Column(
//             children: [
//               const Text(
//                 "Select Customer",
//                 style: TextStyle(fontSize: 20),
//               ),
//               Text(
//                 widget.areaId.name,
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               )
//             ],
//           ),
//           actions: [
//             IconButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const InvoiceListScreen(),
//                     ),
//                   );
//                 },
//                 icon: const Icon(Icons.home))
//           ],
//         ),
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 controller: _controller,
//                 decoration: InputDecoration(
//                   labelText: 'Search Customers',
//                   suffixIcon: _isSearching
//                       ? IconButton(
//                     icon: Icon(Icons.clear),
//                     onPressed: () {
//                       setState(() {
//                         _controller.clear();
//                         filteredItems = List.from(allItems);
//                         _isSearching = false;
//                       });
//                     },
//                   )
//                       : null,
//                 ),
//                 onChanged: (value) {
//                   _searchProducts(value);
//                 },
//               ),
//             ),
//             filteredItems.isNotEmpty
//                 ? Flexible(
//               child: ListView.builder(
//                 itemCount: filteredItems.length,
//                 itemBuilder: (context, index) {
//                   return InkWell(
//                     onTap: () async {
//                       if (checkLicExpDate == 'N') {
//                         // Navigate to next screen directly if checkLicExpDate is 'Y'
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   ProductAutoComplete(
//                                     customer: filteredItems[index],
//                                     area: widget.areaId,
//                                     sector: widget.sectorId,
//                                   ),
//                             ));
//                       } else {
//                         DateTime licenseExpirationDate;
//                         try {
//                           // Parsing the license expiration date
//                           licenseExpirationDate =
//                               DateTime.parse(
//                                   filteredItems[index]
//                                       .lic_exp_date
//                                       .toString());
//                         } catch (e) {
//                           print(
//                               'Error parsing license expiration date: $e');
//                           return; // Return if parsing fails
//                         }
//
//                         if (licenseExpirationDate
//                             .isBefore(DateTime.now())) {
//                           // Show license expired prompt
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title:
//                                 Text('License Expired'),
//                                 content: Text(
//                                     'Your license for ${filteredItems[index].name} has expired.'),
//                                 actions: <Widget>[
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.of(context)
//                                           .pop();
//                                     },
//                                     child: Text('OK'),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         } else {
//                           // Show confirmation dialog
//                           bool available = await _invoiceData(
//                               filteredItems[index]);
//                           if (available) {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext
//                               buildContext) {
//                                 return AlertDialog(
//                                   title:
//                                   Text('Are you sure?'),
//                                   content: Text(
//                                       'It will create another order for this customer'),
//                                   actions: <Widget>[
//                                     TextButton(
//                                       child: Text('Yes'),
//                                       onPressed: () {
//                                         Navigator.pop(
//                                             context);
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder:
//                                                   (context) =>
//                                                   ProductAutoComplete(
//                                                     customer:
//                                                     filteredItems[
//                                                     index],
//                                                     area: widget
//                                                         .areaId,
//                                                     sector: widget
//                                                         .sectorId,
//                                                   ),
//                                             ));
//                                       },
//                                     ),
//                                     TextButton(
//                                       child: Text('Cancel'),
//                                       onPressed: () {
//                                         Navigator.of(context)
//                                             .pop();
//                                       },
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           } else {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       ProductAutoComplete(
//                                         customer: filteredItems[index],
//                                         area: widget.areaId,
//                                         sector: widget.sectorId,
//                                       ),
//                                 ));
//                           }
//                         }
//                       }
//                     },
//                     child: Card(
//                       color: filteredItems[index].cardColor,
//                       child: Padding(
//                         padding:
//                         const EdgeInsets.only(left: 16),
//                         child: Row(
//                           mainAxisAlignment:
//                           MainAxisAlignment.end,
//                           crossAxisAlignment:
//                           CrossAxisAlignment.end,
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.start,
//                                 crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     filteredItems[index].name,
//                                     style:  TextStyle(
//                                         color: filteredItems[index].cardColor != null ? Colors.white : Colors.black,
//                                         fontSize: 14,
//                                         fontWeight:
//                                         FontWeight.bold),
//                                   ),
//                                   Text(filteredItems[index]
//                                       .address , style: TextStyle(
//                                     color: filteredItems[index].cardColor != null ? Colors.white : Colors.black,),),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             )
//                 : Center(child: Text('No customers found')),
//           ],
//         ),
//         resizeToAvoidBottomInset: false,
//       ),
//     );
//   }
//
//   void _searchProducts(String query) {
//     if (query.isNotEmpty) {
//       setState(() {
//         _isSearching = true;
//         filteredItems = allItems.where((item) => item.name.toLowerCase().startsWith(query.toLowerCase())).toList();
//       });
//     } else {
//       setState(() {
//         _isSearching = false;
//         filteredItems = List.from(allItems);
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
