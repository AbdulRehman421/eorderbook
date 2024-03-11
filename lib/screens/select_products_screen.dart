import 'dart:async';

import 'package:eorderbook/models/account.dart';
import 'package:eorderbook/models/area.dart';
import 'package:eorderbook/models/eorderbook_master.dart';
import 'package:eorderbook/models/product.dart';
import 'package:eorderbook/models/sector.dart';
import 'package:eorderbook/screens/invoice_list_screen.dart';
import 'package:eorderbook/screens/select_customer_screen.dart';
import 'package:eorderbook/services/db_helper.dart';
import 'package:eorderbook/utils/Utils.dart';
import 'package:eorderbook/widgets/ConstantWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SelectProductsScreen extends StatefulWidget {
  final Account customer;
  final Area area;
  final Sector sector;

  const SelectProductsScreen(
      {Key? key,
        required this.customer,
        required this.area,
        required this.sector})
      : super(key: key);

  @override
  State<SelectProductsScreen> createState() => _SelectProductsScreenState();
}

class _SelectProductsScreenState extends State<SelectProductsScreen> {

  bool visibility = true;
  final ScrollController _scrollController = ScrollController();
  List<Product> items = [];

  bool isButtonVisible = true;
  final int pageSize = 20; // number of items to display per page
  int currentPage = 1; // current page number, starting from 1
  bool isLoading = false;
  Timer? _debounce;

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      searchFromStart
      ?_loadMoreItemsStarting()
      :_loadMoreItems();

    }
  }

  void _loadMoreItems() async {
    final int offset = currentPage * pageSize;

    final List<Product> newItems = await fetchItems(offset, pageSize);
    setState(() {
      controller.text.isNotEmpty
          ? _searchResult.addAll(newItems)
          : items.addAll(newItems);

      currentPage++;
      isLoading = false;
    });
  }
  void _loadMoreItemsStarting() async {
    final int offset = currentPage * pageSize;

    final List<Product> newItems = await fetchStartingItems(offset, pageSize);
    setState(() {
      controller.text.isNotEmpty
          ? _searchResult.addAll(newItems)
          : items.addAll(newItems);

      currentPage++;
      isLoading = false;
    });
  }

  Future<List<Product>> fetchItems(int offset, int limit) async {
    List<Product> fetched = [];
    setState(() {
      isLoading = true;
    });
    final dbPath = path.join(await getDatabasesPath(), 'eOrderBook.db');
    Database database = await openDatabase(dbPath);
    int? count = controller.text.isNotEmpty
        ? Sqflite.firstIntValue(await database.rawQuery(
        "SELECT COUNT(*) FROM product WHERE name LIKE '%${controller.text}%' OR pcode LIKE '%${controller.text}%'"))
        : Sqflite.firstIntValue(
        await database.rawQuery("SELECT COUNT(*) FROM Product"));

    debugPrint("Product count $count");

    List<Map<String, dynamic>> products = controller.text.isNotEmpty
        ? await database.rawQuery(
        "SELECT * FROM product WHERE name LIKE '%${controller.text}%' OR pcode LIKE '%${controller.text}%' ORDER BY name LIMIT $limit OFFSET $offset")
        : await database.rawQuery(
        "SELECT * FROM product ORDER BY name LIMIT $limit OFFSET $offset");
    database.close();
    if (products.length <= count!) {
      isLoading = false;
    }

    for (var product in products) {
      double price = 0;
      try {
        price = double.parse("${product['tp']}");
      } catch (e) {
        debugPrint(e.toString());
      }
      Product p = Product(
          pCode: product['pcode'] ?? "",
          name: product['name'],
          tp: price,
          rp: 0,
          discount: 0,
          quantity: 0,
          id: product['ID'],
          balance: product['balance'],
          active: product['active'],
          distCode: product['dist_code'],
          cmpCd: product['cmpcd'],
          grCd: product['grcd']);
      final index = selectedProducts.indexWhere((element) => element.pCode == product['pcode']);
      if (index >= 0) {
        p.selected = selectedProducts[index].selected;
        p.discount = selectedProducts[index].discount;
        p.quantity = selectedProducts[index].quantity;
      }

      fetched.add(p);
    }
    await Future.delayed(const Duration(milliseconds: 500));

    return fetched;
  }

  Future<List<Product>> fetchStartingItems(int offset, int limit) async {
    List<Product> fetched = [];
    setState(() {
      isLoading = true;
    });

    final dbPath = path.join(await getDatabasesPath(), 'eOrderBook.db');
    Database database = await openDatabase(dbPath);

    // Construct the WHERE clause to search only from the start
    String whereClause = controller.text.isNotEmpty
        ? "name LIKE '${controller.text}%' OR pcode LIKE '${controller.text}%'"
        : "";

    int? count = controller.text.isNotEmpty
        ? Sqflite.firstIntValue(await database.rawQuery(
        "SELECT COUNT(*) FROM product WHERE $whereClause"))
        : Sqflite.firstIntValue(
        await database.rawQuery("SELECT COUNT(*) FROM Product"));

    debugPrint("Product count $count");

    // Construct the query to search only from the start and order alphabetically
    String query = controller.text.isNotEmpty
        ? "SELECT * FROM product WHERE $whereClause ORDER BY name LIMIT $limit OFFSET $offset"
        : "SELECT * FROM product ORDER BY name LIMIT $limit OFFSET $offset";

    List<Map<String, dynamic>> products = await database.rawQuery(query);
    database.close();

    if (products.length <= count!) {
      isLoading = false;
    }

    for (var product in products) {
      double price = 0;
      try {
        price = double.parse("${product['tp']}");
      } catch (e) {
        debugPrint(e.toString());
      }

      Product p = Product(
        pCode: product['pcode'] ?? "",
        name: product['name'],
        tp: price,
        rp: 0,
        discount: 0,
        quantity: 0,
        id: product['ID'],
        balance: product['balance'],
        active: product['active'],
        distCode: product['dist_code'],
        cmpCd: product['cmpcd'],
        grCd: product['grcd'],
      );

      final index =
      selectedProducts.indexWhere((element) => element.pCode == product['pcode']);
      if (index >= 0) {
        p.selected = selectedProducts[index].selected;
        p.discount = selectedProducts[index].discount;
        p.quantity = selectedProducts[index].quantity;
      }

      fetched.add(p);
    }

    await Future.delayed(const Duration(milliseconds: 500));

    return fetched;
  }



  initial() async {
    if (controller.text.isNotEmpty) {
      _searchResult.clear();
    } else {
      items.clear();
    }

    controller.text.isNotEmpty
        ? _searchResult.addAll(await fetchItems(0, 20))
        : items.addAll(await fetchItems(0, 20));

    setState(() {});
  }
  initialStart() async {
    if (controller.text.isNotEmpty) {
      _searchResult.clear();
    } else {
      items.clear();
    }

    controller.text.isNotEmpty
        ? _searchResult.addAll(await fetchStartingItems(0, 20))
        : items.addAll(await fetchStartingItems(0, 20));

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _debounce?.cancel();
    searchFromStart
    ?initialStart()
    :initial();
    _scrollController.addListener(_onScroll);
    getInvoiceId();
    debugPrint(widget.customer.toString());
    loadPreferences();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int generatedInvoiceId = 0;

  Future<int> getLastInsertedId() async {
    final dbPath = path.join(await getDatabasesPath(), 'eOrderBook.db');
    Database database = await openDatabase(dbPath);
    List<Map<String, dynamic>> result = await database.rawQuery(
        'SELECT max(order_id) as id FROM eorderbook_master');

    database.close();

    if (result.isNotEmpty && result.first['id'] != null) {
      return result.first['id'];
    } else {
      return 0;
    }
  }

  Future<void> getInvoiceId() async {
    try {
      int lastInvoiceId = await getLastInsertedId();
      setState(() {
        generatedInvoiceId =
            Utils.generateInvoiceId((lastInvoiceId + 1).toString());
      });
    } catch (e) {
      setState(() {
        generatedInvoiceId = Utils.generateInvoiceId(1.toString());
      });
      debugPrint("Error getting invoice id: $e");
    }
    if (kDebugMode) {
      debugPrint("generated invoice id: $generatedInvoiceId");
    }
  }

  TextEditingController controller = TextEditingController();

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var userDetail in items) {
      if (userDetail.name
          .trim()
          .toLowerCase()
          .contains(text.trim().toLowerCase())) {
        _searchResult.add(userDetail);
      }
    }

    _searchResult.sort((a, b) => a.name.compareTo(b.name));

    setState(() {});
  }

  List<Product> _searchResult = [];

  double totalPrice = 0;
  bool showSelected = true;
  bool showPositiveBalanceOnly = true;
  bool searchFromStart = true;
  bool searchRefresh = true;
  // bool searchThreeDigit = true;
  bool searchOnTap = false;



  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showSelected = prefs.getBool('showSelected') ?? true;
      showPositiveBalanceOnly = prefs.getBool('showPositiveBalanceOnly') ?? true;
      searchFromStart = prefs.getBool('searchFromStart') ?? true;
      searchRefresh = prefs.getBool('searchRefresh') ?? true;
      // searchThreeDigit = prefs.getBool('searchThreeDigit') ?? true;
      searchOnTap = prefs.getBool('searchOnTap') ?? false;
    });
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('showSelected', showSelected);
    prefs.setBool('showPositiveBalanceOnly', showPositiveBalanceOnly);
    prefs.setBool('searchFromStart', searchFromStart);
    prefs.setBool('searchRefresh', searchRefresh);
    // prefs.setBool('searchThreeDigit', searchThreeDigit);
    prefs.setBool('searchOnTap', searchOnTap);
  }

  Future<Position> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return Position(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: position.timestamp ?? DateTime.now(),
        accuracy: position.accuracy ?? 0.0,
        altitude: position.altitude ?? 0.0,
        altitudeAccuracy: position.altitudeAccuracy ?? 0.0,
        heading: position.heading ?? 0.0,
        headingAccuracy: position.headingAccuracy ?? 0.0,
        speed: position.speed ?? 0.0,
        speedAccuracy: position.speedAccuracy ?? 0.0,
        floor: position.floor ?? 0,
        isMocked: position.isMocked ?? false,
      );
    } catch (e) {
      // Handle exceptions (e.g., location services disabled)
      print("Error getting location: $e");
      return Position(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        floor: 0,
        isMocked: false,
      );
    }
  }
  List<String> options = [
    "No Order",
    "Shop Closed",
    "Other"
  ];
  Future<bool> showSendingConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("DELETE"),
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
    // final _items = CryptoModel.getCrypto();
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Column(
            children: [
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    widget.customer.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  '(Total : ${totalPrice.toStringAsFixed(2)}) ${widget.area.name} ',
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
          actions: [
            items.isNotEmpty || getSelectedItem().isNotEmpty
                ? Visibility(
              visible: isButtonVisible,
                  child: IconButton(
                  onPressed: () async {



                    if (getSelectedItem().isNotEmpty) {
                      bool locationEnabled = await Geolocator.isLocationServiceEnabled();
                      if (!locationEnabled) {
                        // Show a dialog to enable location services
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Enable Location"),
                              content: Text("Please enable location services to proceed."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {

                        LocationPermission permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          // Show a toast or dialog indicating that location permission is required
                          Fluttertoast.showToast(
                            msg: "Location permission is required to proceed.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey[600],
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {

                          // Request location permissions if not granted
                          if (permission == LocationPermission.deniedForever) {
                            // Show a dialog or navigate to settings to enable location services

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Enable Location"),
                                  content: Text("Please enable location services in your device settings to proceed."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {

                            // Location permission granted or not permanently denied, proceed to get location
                            try {
                              await Utils.showLoaderDialog(context ,"Sending data", "Please wait..." );
                              setState(() {
                                isButtonVisible = false; // Set visibility to false when the button is clicked
                              });
                              Position position = await _getCurrentLocation();
                              print('selcted items ${selectedProducts}');
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              final username = prefs.getString('username');
                              EOrderBookMaster order = EOrderBookMaster(
                                remarks: "OK",
                                latitude: position.latitude.toString(),
                                longitude: position.longitude.toString(),
                                userName: username!,
                                distCode: widget.area.distCode,
                                appOrderNo: generatedInvoiceId,
                                code: widget.customer.code,
                                date: DateTime.now().toString(),
                                orderAmount: totalPrice,
                              );

                              debugPrint("date: ${DateTime.now()}");

                              await DatabaseHelper.instance.insertOrder(order.toMap(), getSelectedItem());

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectCustomerScreen(
                                      areaId: widget.area, sectorId: widget.sector),
                                ),
                                  (Route<dynamic> route) => false,
                              );
                            } catch (e) {

                              // Handle the case when location is not available
                              print("Order Creation Failed: $e");
                              Fluttertoast.showToast(
                                msg: "Order Creation Failed",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.grey[600],
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          }
                        }
                      }
                    } else {

                      try {
                        bool confirmEmptyOrder = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Empty Order",textAlign: TextAlign.center),
                              content: Text("Do you want to save the order without products?"),
                              actions: [
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, false); // User selected No
                                      },
                                      child: Text("No"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, true); // User selected Yes
                                      },
                                      child: Text("Yes"),
                                    ),
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                )
                              ],
                            );
                          },
                        );
                       if(confirmEmptyOrder != null && confirmEmptyOrder){
                         String? selectedOption = await showDialog(
                           context: context,
                           builder: (context) {
                             TextEditingController otherOptionController = TextEditingController();

                             bool isTextEntered = false;

                             return AlertDialog(
                               title: Text("Select an Option"),
                               content: Column(
                                 mainAxisSize: MainAxisSize.min,
                                 children: options.map((option) {
                                   if (option == "Other") {
                                     return ListTile(
                                       title: TextFormField(
                                         controller: otherOptionController,
                                         decoration:
                                         InputDecoration(labelText: "Enter Other Option"),
                                         onChanged: (value) {
                                           setState(() {
                                             isTextEntered = value.isNotEmpty;
                                           });
                                         },
                                       ),
                                       onTap: () =>
                                           Navigator.pop(context, otherOptionController.text),
                                     );
                                   } else {
                                     return ListTile(
                                       title: Text(option),
                                       onTap: () => Navigator.pop(context, option),
                                     );
                                   }
                                 }).toList(),
                               ),
                               actions: [
                                 Row(
                                   children: [
                                     ElevatedButton(
                                       onPressed: () {
                                         Navigator.push(
                                           context,
                                           MaterialPageRoute(
                                             builder: (context) => InvoiceListScreen(),
                                           ),
                                         );
                                       },
                                       child: Text('Cancel'),
                                     ),
                                     ElevatedButton(
                                       onPressed: () {
                                         Navigator.pop(context, otherOptionController.text);
                                       },
                                       child: Text('Submit'),
                                     ),
                                   ],
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 )

                               ],
                             );
                           },
                         );

                         if (selectedOption != null && selectedOption.isNotEmpty) {
                           // Continue with your logic using the selectedOption
                           await Utils.showLoaderDialog(
                               context, "Sending data", "Please wait...");
                           setState(() {
                             isButtonVisible = false;
                           });

                           Position position = await _getCurrentLocation();
                           SharedPreferences prefs = await SharedPreferences.getInstance();
                           final username = prefs.getString('username');
                           EOrderBookMaster order = EOrderBookMaster(
                             remarks: selectedOption.toString(),
                             latitude: position.latitude.toString(),
                             longitude: position.longitude.toString(),
                             userName: username!,
                             distCode: widget.area.distCode,
                             appOrderNo: generatedInvoiceId,
                             code: widget.customer.code,
                             date: DateTime.now().toString(),
                             orderAmount: totalPrice,
                           );

                           await DatabaseHelper.instance
                               .insertOrder(order.toMap(), getSelectedItem());

                           Navigator.pushAndRemoveUntil(
                             context,
                             MaterialPageRoute(
                               builder: (context) => SelectCustomerScreen(
                                 areaId: widget.area,
                                 sectorId: widget.sector,
                               ),
                             ),
                                 (Route<dynamic> route) => false,
                           );
                         }
                       }
                      } catch (e) {
                        print("Order Creation Failed: $e");
                        Fluttertoast.showToast(
                          msg: "Order Creation Failed",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey[600],
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }

                      


                      // Fluttertoast.showToast(
                      //   msg: "Please select a product",
                      //   toastLength: Toast.LENGTH_SHORT,
                      //   gravity: ToastGravity.BOTTOM,
                      //   timeInSecForIosWeb: 1,
                      //   backgroundColor: Colors.grey[600],
                      //   textColor: Colors.white,
                      //   fontSize: 16.0,
                      // );
                    }
                  },
                  icon : Visibility(
                      visible: visibility, child: Icon(Icons.check_circle_outline,color: Colors.green,))),
                )
                : const SizedBox(),
            SizedBox(
              width: 10,
            ),
          ],
          leading: IconButton(onPressed: () async {
            bool confirmCancelOrder = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Cancel Order",textAlign: TextAlign.center),
                  content: Text("Do you want to cancel the order?"),
                  actions: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, false); // User selected No
                          },
                          child: Text("No"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true); // User selected Yes
                          },
                          child: Text("Yes"),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    )
                  ],
                );
              },
            );
            if(confirmCancelOrder != null && confirmCancelOrder) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SelectCustomerScreen(
                          areaId: widget.area, sectorId: widget.sector),
                ),
                    (Route<dynamic> route) => false,
              );
            }
          }, icon: Icon(Icons.cancel_outlined,color: Colors.red,))
        ),
        body: Stack(
          children: [
            GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: ListView(
                controller: _scrollController,
                children: [
                  Visibility(
                    visible: visibility,
                    child: items.isNotEmpty
                        ? Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green)),
                          child: ListTile(
                            contentPadding:
                            const EdgeInsets.only(left: 6, right: 0),
                            leading: const Icon(Icons.search),
                            title: TextField(
                              onSubmitted: (value) {
                                  onSearchTextChanged(value);
                                  setState(() {});
                                  searchFromStart ? initialStart() : initial();
                              },
                              controller: controller,
                              decoration: const InputDecoration(
                                  hintText: 'Search',
                                  border: InputBorder.none),
                              textInputAction: TextInputAction.search,
                              onChanged: (value) {
                               if(!searchOnTap){
                                 if (_debounce?.isActive ?? false) _debounce!.cancel();
                                 _debounce = Timer(const Duration(milliseconds: 500), () {
                                     onSearchTextChanged(value);
                                     setState(() {});
                                     searchFromStart ? initialStart() : initial();
                                 });
                               }
                              },
                            ),
                            trailing: SizedBox(
                              width: 40,
                              child: InkWell(
                                child: const Icon(
                                  Icons.cancel,
                                  size: 28,
                                ),
                                onTap: () {
                                  controller.clear();
                                  onSearchTextChanged('');
                                  FocusManager.instance.primaryFocus
                                      ?.hasPrimaryFocus;
                                },
                              ),
                            ),
                          ),
                        ),

                        _searchResult.isNotEmpty ||
                            controller.text.isNotEmpty
                            ? Column(
                          children: [
                            ListView.builder(
                              itemBuilder: (context, index) {
                             if (!showPositiveBalanceOnly ||
                             (_searchResult[index].balance > 0)) {
                               return InkWell(
                                  onTap: () async {
                                    if (!_searchResult[index]
                                        .selected) {
                                      showEditProductDialog(
                                          context,
                                          _searchResult[index],
                                          index);
                                    }
                                  },
                                  child:  Card(
                                    color: _searchResult[index]
                                        .selected ? Colors.green : Colors.white,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.end,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _searchResult[
                                                        index]
                                                            .name +
                                                            "        " +
                                                            _searchResult[
                                                            index]
                                                                .pCode +
                                                            '(${_searchResult[index].balance})',
                                                        style: const TextStyle(
                                                            fontSize:
                                                            13,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          'Price:',
                                                          style: TextStyle(
                                                              fontSize:
                                                              13),
                                                        ),
                                                        Text(
                                                          '${_searchResult[index].tp}',
                                                          style: const TextStyle(
                                                              fontSize:
                                                              13),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          'Disc:',
                                                          style: TextStyle(
                                                              fontSize:
                                                              13),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              12.0,
                                                              vertical:
                                                              4),
                                                          child:
                                                          Text(
                                                            '${_searchResult[index].discount}',
                                                            style: const TextStyle(
                                                                fontSize:
                                                                13),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          'Bns:',
                                                          style: TextStyle(
                                                              fontSize:
                                                              13),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              12.0,
                                                              vertical:
                                                              4),
                                                          child:
                                                          Text(
                                                            '${_searchResult[index].bonus}',
                                                            style: const TextStyle(
                                                                fontSize:
                                                                13),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          'Qty:',
                                                          style: TextStyle(
                                                              fontSize:
                                                              13),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              12.0,
                                                              vertical:
                                                              4),
                                                          child:
                                                          Text(
                                                            '${_searchResult[index].quantity}',
                                                            style: const TextStyle(
                                                                fontSize:
                                                                13),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            children: [
                                              const SizedBox(
                                                height: 6,
                                              ),
                                              !_searchResult[index]
                                                  .selected
                                                  ? Container()
                                                  : CircleAvatar(
                                                maxRadius: 16,
                                                backgroundColor:
                                                Colors.red,
                                                child:
                                                GestureDetector(
                                                  onTap:
                                                      () async {
                                                    showSearchWarningAlert(
                                                        context,
                                                        index,
                                                        0);
                                                  },
                                                  child:
                                                  const Icon(
                                                    Icons
                                                        .remove,
                                                    size: 18,
                                                    color: Colors
                                                        .white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 6,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }else {
                                return Container();
                                }
                              },
                              itemCount: _searchResult.isEmpty
                                  ? 0
                                  : _searchResult.length,
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                            ),
                          ],
                        )
                          :Column(
                          children: [
                            ListView.builder(
                              itemBuilder: (context, index) {
                                if (!showPositiveBalanceOnly ||
                                    (items[index].balance > 0)) {
                                  return InkWell(
                                    onTap: () async {
                                      if (!items[index]
                                          .selected) {
                                        showEditProductDialog(
                                            context,
                                            items[index],
                                            index);
                                      }
                                    },
                                    child:  Card(
                                      color: items[index]
                                          .selected ? Colors.green : Colors.white,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          items[
                                                          index]
                                                              .name +
                                                              "        " +
                                                              items[
                                                              index]
                                                                  .pCode +
                                                              '(${items[index].balance})',
                                                          style: const TextStyle(
                                                              fontSize:
                                                              13,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'Price:',
                                                            style: TextStyle(
                                                                fontSize:
                                                                13),
                                                          ),
                                                          Text(
                                                            '${items[index].tp}',
                                                            style: const TextStyle(
                                                                fontSize:
                                                                13),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'Disc:',
                                                            style: TextStyle(
                                                                fontSize:
                                                                13),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                12.0,
                                                                vertical:
                                                                4),
                                                            child:
                                                            Text(
                                                              '${items[index].discount}',
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                  13),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'Bns:',
                                                            style: TextStyle(
                                                                fontSize:
                                                                13),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                12.0,
                                                                vertical:
                                                                4),
                                                            child:
                                                            Text(
                                                              '${items[index].bonus}',
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                  13),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'Qty:',
                                                            style: TextStyle(
                                                                fontSize:
                                                                13),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                12.0,
                                                                vertical:
                                                                4),
                                                            child:
                                                            Text(
                                                              '${items[index].quantity}',
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                  13),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              children: [
                                                const SizedBox(
                                                  height: 6,
                                                ),
                                                !items[index]
                                                    .selected
                                                    ? Container()
                                                    : CircleAvatar(
                                                  maxRadius: 16,
                                                  backgroundColor:
                                                  Colors.red,
                                                  child:
                                                  GestureDetector(
                                                    onTap:
                                                        () async {
                                                      showSearchWarningAlert(
                                                          context,
                                                          index,
                                                          0);
                                                    },
                                                    child:
                                                    const Icon(
                                                      Icons
                                                          .remove,
                                                      size: 18,
                                                      color: Colors
                                                          .white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 6,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }else {
                                  return Container();
                                }
                              },
                              itemCount: items.isEmpty
                                  ? 0
                                  : items.length,
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                            ),
                          ],
                        ),
                        Visibility(
                          visible:
                          selectedProducts.isNotEmpty && showSelected,
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  "Selected",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              ListView.builder(
                                itemBuilder: (context, index) {
                                  return productItem(
                                      selectedProducts, index);
                                },
                                itemCount: selectedProducts.length,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        if (isLoading)
                          const SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator()),
                        const SizedBox(
                          height: 100,
                        )
                      ],
                    )
                        : ConstantWidget.NotFoundWidget(
                        context, "Product not added yet"),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
          _appNotification();
        },child: Icon(Icons.settings)),
        resizeToAvoidBottomInset: false,
      ),
    );
  }


  void _appNotification() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '      Setting',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF38106A),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.cancel),
                      )
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Show Selected Product'),
                  trailing: CupertinoSwitch(
                    value: showSelected,
                    onChanged: (value) {
                      stateSetter(() {
                        showSelected = value;
                        savePreferences();
                        setState(() {});
                      });
                    },
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Show positive balance only'),
                  trailing: CupertinoSwitch(
                    value: showPositiveBalanceOnly,
                    onChanged: (value) {
                      stateSetter(() {
                        showPositiveBalanceOnly = value;
                        savePreferences();
                        setState(() {});
                      });
                    },
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Search from start'),
                  trailing: CupertinoSwitch(
                    value: searchFromStart,
                    onChanged: (value) {
                      stateSetter(() {
                        searchFromStart = value;
                        savePreferences();
                        setState(() {});
                      });
                    },
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Search List Refresh'),
                  trailing: CupertinoSwitch(
                    value: searchRefresh,
                    onChanged: (value) {
                      stateSetter(() {
                        searchRefresh = value;
                        savePreferences();
                        setState(() {});
                      });
                    },
                  ),
                ),
                // Divider(),
                // ListTile(
                //   title: Text('Search From 3 Digits'),
                //   trailing: CupertinoSwitch(
                //     value: searchThreeDigit,
                //     onChanged: (value) {
                //       stateSetter(() {
                //         searchThreeDigit = value;
                //         savePreferences();
                //       });
                //     },
                //   ),
                // ),
                Divider(),
                ListTile(
                  title: Text('Search by Button'),
                  trailing: CupertinoSwitch(
                    value: searchOnTap,
                    onChanged: (value) {
                      stateSetter(() {
                        searchOnTap = value;
                        savePreferences();
                        setState(() {});
                      });
                    },
                  ),
                ),
                Divider(),
              ],
            );
          },
        );
      },
    );
  }




  bool editing = true;
  String? editingId;
  List<Product> selectedProducts = [];
  List selectedProductss = ["14070" ,"WARIOR INFU 100ML" , 200.5 , 5,0.0,109566 , true ];

  List getSelectedItemss() {
    return selectedProductss;
  }
  List<Product> getSelectedItem() {
    return selectedProducts;
  }

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  int findProductUsingIndexWhere(List<Product> product, String pCode) {
    // Find the index of person. If not found, index = -1
    final index = product.indexWhere((element) => element.pCode == pCode);
    if (index >= 0) {
      debugPrint('Using indexWhere: ${product[index]}');
    }
    return index;
  }

  void showWarningAlert(BuildContext context, int index, type) {
    int searchIndex =
    findProductUsingIndexWhere(_searchResult, items[index].pCode);

    AlertDialog alertDialog = AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        width: double.maxFinite,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
              child: Text(
                "Are you sure?",
                style: TextStyle(color: Colors.white),
              )),
        ),
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstantWidget.SmallWarningWidget(context),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Do you want to ${type == 1 ? "add " : "remove "}${items[index].name}?",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.red),
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 24))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("No", style: TextStyle(color: Colors.white),)),
                  ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 24))),
                      onPressed: () async {
                        debugPrint("$index     $searchIndex");
                        setState(() {
                          if (searchIndex != -1) {
                            _searchResult[searchIndex].selected = false;
                          }
                          if (index != -1) {
                            items[index].selected = false;
                          }
                          selectedProducts.removeWhere(
                                (element) => items[index].pCode == element.pCode,
                          );
                          totalPrice = Product.getTotal(selectedProducts);
                          debugPrint("total $totalPrice");

                          controller.clear();
                          onSearchTextChanged('');
                          // FocusManager.instance.primaryFocus;
                          FocusManager.instance.primaryFocus
                              ?.hasPrimaryFocus;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Yes")),
                ],
              )
            ],
          ),
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  void showSearchWarningAlert(BuildContext context, int index, type) {
    int productIndex =
    findProductUsingIndexWhere(items, _searchResult[index].pCode);
    AlertDialog alertDialog = AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        width: double.maxFinite,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
              child: Text(
                "Are you sure?",
                style: TextStyle(color: Colors.white),
              )),
        ),
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstantWidget.SmallWarningWidget(context),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Do you want to ${type == 1 ? "add " : "remove "}${_searchResult[index].name}?",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.red),
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 24))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("No", style: TextStyle(color: Colors.white),)),
                  ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 24))),
                      onPressed: () async {
                        setState(() {
                          if (index != -1) {
                            _searchResult[index].selected = false;
                          }

                          if (productIndex != -1) {
                            items[productIndex].selected = false;
                          }

                          selectedProducts.removeWhere((element) =>
                          _searchResult[index].pCode == element.pCode);
                          totalPrice = Product.getTotal(selectedProducts);
                          debugPrint("total $totalPrice");

                          controller.clear();
                          onSearchTextChanged('');
                          // FocusManager.instance.primaryFocus;
                          FocusManager.instance.primaryFocus
                              ?.hasPrimaryFocus;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Yes")),
                ],
              )
            ],
          ),
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  void showSelectedWarningAlert(BuildContext context, int index, type) {
    int productIndex = findProductUsingIndexWhere(
        items, selectedProducts[index].pCode);
    int searchIndex = findProductUsingIndexWhere(
        _searchResult, selectedProducts[index].pCode);
    AlertDialog alertDialog = AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        width: double.maxFinite,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
              child: Text(
                "Are you sure?",
                style: TextStyle(color: Colors.white),
              )),
        ),
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstantWidget.SmallWarningWidget(context),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Do you want to ${type == 1 ? "add " : "remove "}${selectedProducts[index].name}?",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.red),
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 24))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("No", style: TextStyle(color: Colors.white),)),
                  ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 24))),
                      // onPressed: () async {
                      //   setState(() {
                      //     if (searchIndex != -1) {
                      //       _searchResult[searchIndex].selected = false;
                      //     }
                      //
                      //     if (productIndex != -1) {
                      //       items[productIndex].selected = false;
                      //       selectedProducts.removeWhere((element) =>
                      //       items[productIndex].pCode == element.pCode);
                      //       totalPrice = Product.getTotal(selectedProducts);
                      //       debugPrint("total $totalPrice");
                      //     }
                      //
                      //     controller.clear();
                      //     onSearchTextChanged('');
                      //     // FocusManager.instance.primaryFocus;
                      //     FocusManager.instance.primaryFocus
                      //         ?.hasPrimaryFocus;
                      //   });
                      //   Navigator.pop(context);
                      // },
                      onPressed: () {
                        onDelete(index);
                        Navigator.of(context).pop();
                      },
                      child: const Text("Yes")),
                ],
              )
            ],
          ),
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  void showEditProductDialog(BuildContext context, Product product, int index) {
    var countQuantity = product.quantity;
    var countBonus = product.bonus;
    TextEditingController quantityController = TextEditingController();
    if (countQuantity < 1) {
      quantityController.text = "";
    } else {
      quantityController.text = countQuantity.toStringAsFixed(0);
    }
    TextEditingController bonusController = TextEditingController();
    if (countBonus < 1) {
      bonusController.text = "0";
    } else {
      bonusController.text = countQuantity.toStringAsFixed(0);
    }
    var discountC = TextEditingController();
    var priceC = TextEditingController();
    discountC.text = product.discount.toStringAsFixed(0);
    // priceC.text = product.tp.toStringAsFixed(0);
    priceC.text = double.parse(product.tp.toString()).toString();
    int searchIndex =
    findProductUsingIndexWhere(_searchResult, product.pCode);
    int productIndex = findProductUsingIndexWhere(items, product.pCode);

    if (_searchResult.isNotEmpty) {
      _searchResult[searchIndex].selected = false;
    }
    setState(() {});
    AlertDialog alertDialog = AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        width: double.maxFinite,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
              child: Text(
                "Add Additional",
                style: TextStyle(color: Colors.white),
              )),
        ),
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.0, top: 12),
                      child: Text("Quantity: "),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 20,
                          child: TextField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              hintText: "Quantity",
                              alignLabelWithHint: true,
                            ),
                            onChanged: (val) {
                              quantityController.text;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text("Price"),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: TextField(
                        controller: priceC,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        maxLines: 1,
                        onTap: () => priceC.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: priceC.value.text.length),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          hintText: "Price",
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text("Discount"),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: TextField(
                        controller: discountC,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        onTap: () => discountC.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: discountC.value.text.length),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          hintText: "Discount",
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.0, top: 12),
                      child: Text("Bonus: "),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 20,
                          child: TextField(
                            controller: bonusController,
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            onTap: () => bonusController.selection =
                                TextSelection(
                                    baseOffset: 0,
                                    extentOffset:
                                    bonusController.value.text.length),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              hintText: "Bonus",
                              alignLabelWithHint: true,
                            ),
                            onChanged: (val) {
                              bonusController.text;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.red),
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 24))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel", style: TextStyle(color: Colors.white),)),
                  ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 24))),
                      onPressed: () async {
                        debugPrint("$searchIndex .... $productIndex");
                        debugPrint(_searchResult.toString());
                        if(quantityController.text.isEmpty){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Quantity Error"),
                                content: Text("Please enter a quantity."),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }
                        try {
                          items[productIndex].quantity =
                              int.parse(quantityController.text);
                          items[productIndex].discount =
                              double.parse(discountC.text);
                          items[productIndex].selected = true;
                          items[productIndex].tp = double.parse(priceC.text);
                          items[productIndex].bonus =
                              int.parse(bonusController.text);
                        } catch (e) {
                          debugPrint(e.toString());
                        }
                        try {
                          if (_searchResult.isNotEmpty) {
                            _searchResult[searchIndex].quantity =
                                int.parse(quantityController.text);
                            _searchResult[searchIndex].discount =
                                double.parse(discountC.text);
                            _searchResult[searchIndex].selected = true;
                            _searchResult[searchIndex].tp =
                                double.parse(priceC.text);
                            _searchResult[searchIndex].bonus =
                                int.parse(bonusController.text);
                          }
                        } catch (e) {
                          debugPrint(e.toString());
                        }

                        if (productIndex != -1) {
                          debugPrint(productIndex.toString());
                          selectedProducts.add(items[productIndex]);
                        } else if (searchIndex != -1) {
                          debugPrint(searchIndex.toString());
                          selectedProducts.add(_searchResult[searchIndex]);
                        }

                        totalPrice = Product.getTotal(selectedProducts);
                       if(searchRefresh == true){
                         controller.clear();
                         onSearchTextChanged('');
                         // FocusManager.instance.primaryFocus;
                         FocusManager.instance.primaryFocus
                             ?.hasPrimaryFocus;
                         setState(() {});
                       }else{

                         setState(() {});
                       }

                        Navigator.pop(context);
                      },
                      child: const Text("Submit")),
                ],
              )
            ],
          ),
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }
  void onDelete(int index) {
    // Ensure that the index is within bounds
    if (index >= 0 && index < selectedProducts.length) {
      // Use setState if you're using a StatefulWidget
      setState(() {
        selectedProducts.removeAt(index);
      });
    }
  }

  Widget productItem(List<Product> selectedProducts, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      child: ListTile(
        // contentPadding: const EdgeInsets.all(12),
        selected: selectedProducts[index].selected,
        selectedTileColor: Colors.green,
        selectedColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${selectedProducts[index].name} ${selectedProducts[index].pCode}(${selectedProducts[index].balance})",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Price:',
                            style: TextStyle(fontSize: 13),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 4),
                            child: Text(
                              '${selectedProducts[index].tp}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Disc:',
                            style: TextStyle(fontSize: 13),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 4),
                            child: Text(
                              '${selectedProducts[index].discount}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Bns:',
                            style: TextStyle(fontSize: 13),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 4),
                            child: Text(
                              '${selectedProducts[index].bonus}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Qty:',
                            style: TextStyle(fontSize: 13),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 4),
                            child: Text(
                              '${selectedProducts[index].quantity}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 6,
                ),
                const SizedBox(
                  height: 6,
                ),
                !selectedProducts[index].selected
                    ? Container()
                    : GestureDetector(
                  onTap: () async {
                    showSelectedWarningAlert(context, index, 0);
                  },
                  child: const CircleAvatar(
                    maxRadius: 16,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.remove,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
  Future<void> _askLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    print("Location Permission Status: $status");

    if (status.isGranted) {
      // Permission granted, you can now access the location
      print('Location permission granted');
    } else {
      // Permission denied
      print('Location permission denied');
    }
  }

}
