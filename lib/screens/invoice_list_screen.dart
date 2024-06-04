import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eorderbook/EOrderBookOrders/OrderDetail/orderdetails.dart';
import 'package:eorderbook/EOrderBookOrders/OrderDetail/ordermaps.dart';
import 'package:eorderbook/models/InvoiceData.dart';
import 'package:eorderbook/models/account.dart';
import 'package:eorderbook/models/area.dart';
import 'package:eorderbook/models/product.dart';
import 'package:eorderbook/models/sector.dart';
import 'package:eorderbook/screens/ProductAutoComplete.dart';
import 'package:eorderbook/screens/login_screen.dart';
import 'package:eorderbook/screens/reselect_products_screen.dart';
import 'package:eorderbook/screens/select_sector_and_area_screen.dart';
import 'package:eorderbook/services/api_service.dart';
import 'package:eorderbook/services/db_helper.dart';
import 'package:eorderbook/utils/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../services/distcodedb.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({Key? key}) : super(key: key);

  @override
  _InvoiceListScreenState createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    _getDistCode();
    getInvoices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  List<int> selectedOrderIds = [];

  getInvoices() async {
    final dbPath = path.join(await getDatabasesPath(), 'eOrderBook.db');
    Database database = await openDatabase(dbPath);

    String query = '''
      SELECT eorderbook_master.order_id, eorderbook_master.date,eorderbook_master.remarks, eorderbook_master.order_amount,
            eorderbook_master.app_orderno, account.ID as accId, account.name as accName, account.lic_exp_date as lic_exp_date ,
            account.code, account.dist_code, account.address, account.areacd, account.active
      FROM eorderbook_master
      JOIN account ON eorderbook_master.code = account.code
    ''';

    List<Map<String, dynamic>> result = await database.rawQuery(query);
    if (result.isNotEmpty) {
      myDataList.clear();
      for (Map<String, dynamic> row in result) {
        // Access the order, customer, sector, and area information
        int orderId = row['order_id'];
        String remarks = row['remarks'];
        int orderNumber = row['app_orderno'];
        String partyName = row['accName'];
        int partyId = row['code'];
        String date = row['date'] ?? '';
        int areaCode = row['areacd'];
        int accDistCode = row['dist_code'];
        String accActive = row['active'];
        String lic_exp_date = row['lic_exp_date'];
        int accCode = row['code'];
        String accAddress = row['address'];

        List<Product> products = [];

        String query = '''
          SELECT eorderbook.id, eorderbook.pcode, eorderbook.order_id,eorderbook.rate,eorderbook.qty,
                eorderbook.discount,eorderbook.bonus,product.id as productId, product.cmpcd, product.grcd,
                product.name, product.tp, product.rp, product.balance, product.dist_code, product.active
          FROM eorderbook
          JOIN product ON product.pcode = eorderbook.pcode
          WHERE eorderbook.order_id = ?
        ''';

        List<Map<String, dynamic>> result =
        await database.rawQuery(query, [orderId]);

        if (result.isNotEmpty) {
          for (Map<String, dynamic> row in result) {
            // Access the ordered product information
            int orderedProductId = row['id'];
            int productId = row['productId'];
            int orderId = row['order_id'];
            int qty = row['qty'];
            int bonus = row['bonus'];
            double discount = row['discount'];
            double price = row['rate'];
            double rp = row['rp'];
            String productName = row['name'];
            String productCode = row['pcode'];
            int balance = row['balance'];
            String cmpCd = row['cmpcd'];
            String grCd = row['grcd'];
            int distCode = row['dist_code'];
            String active = row['active'];

            // Print or process the ordered product information
            debugPrint('Ordered Product ID: $orderedProductId');
            debugPrint('Product ID: $productId');
            debugPrint('Order ID: $orderId');
            debugPrint('App Order No: $orderNumber');
            Product p = Product(
              pCode: productCode,
              name: productName,
              tp: price,
              rp: rp,
              quantity: qty,
              discount: discount,
              id: productId,
              balance: balance,
              cmpCd: cmpCd,
              grCd: grCd,
              distCode: distCode,
              active: active,
            );
            p.bonus = bonus;
            p.selected = true;

            products.add(p);
          }
        } else {
          debugPrint('No ordered products found for the specified order ID');
        }
        myDataList.add(MyData(
            products,
            orderId,
            orderNumber,
            "0",
            Account(
                id: partyId,
                name: partyName,
                address: accAddress,
                code: accCode,
                distCode: accDistCode,
                areaCd: areaCode,
                active: accActive,
              lic_exp_date: lic_exp_date,
            ),
            date,
        remarks,
          lic_exp_date
        ));
      }
    } else {
      debugPrint("nothing");
    }
    setState(() {});

    // Close the database
    await database.close();
  }

  bool isLoading = false;
  bool isSelected = false;
  getData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Utils.showToast('No internet connection');
      return false;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Utils.showLoaderDialog(context ,"Syncing data", "Please wait..." );

      bool val = await ApiService().syncData(dist_Code);
      if (val == true) {
        isLoading = false;
        Utils.showToast('Sync successful');
      }
    } catch (e) {
      isLoading = false;
      Utils.showToast('Sync failed');
      debugPrint('Error syncing data: $e');
    }

    Navigator.pop(context);
    setState(() {});
  }

  @override
  void dispose() {
    // routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    debugPrint("Route was pushed onto navigator and is now topmost route. sdg");
  }

  @override
  void didPopNext() {
    debugPrint("Covering route was popped off the navigator. dsgds");
    getInvoices();
  }

  bool selectAll = false;
  String dist_Code = '0';
  Future<void> _getDistCode() async {
    String? distributorCode = await DistcodeDatabaseHelper().getDistributorCode();
    setState(() {
      dist_Code = distributorCode ?? '';
    });
  }
  @override
  Widget build(BuildContext context) {
    double totalSum = 0;
    for (var data in myDataList) {
      totalSum += Product.getTotal(data.products);
    }
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(

        appBar: AppBar(
          centerTitle: true,
          title: Text("E Order Book $dist_Code"),
          actions: [
            Visibility(
              visible:
              selectedOrderIds.length > 0 && selectedOrderIds.isNotEmpty,
              child: IconButton(
                  onPressed: () async{
                    bool confirmDelete =
                    await showDeleteConfirmationDialog(context);
                    if (confirmDelete) {
                      // Perform delete action
                      deleteSelectedData();
                    }

                  },
                  icon: const Icon(
                    Icons.delete_sharp,
                    color: Colors.redAccent,
                  )),
            ),
            Visibility(
              visible:
              selectedOrderIds.length > 0 && selectedOrderIds.isNotEmpty,
              child: IconButton(
                onPressed: () async {
                  var connectivityResult = await Connectivity().checkConnectivity();
                  if (connectivityResult == ConnectivityResult.none) {
                    Utils.showToast('No internet connection');
                    return;
                  }

                  if (myDataList.isEmpty) {
                    Utils.showToast('No data to send');
                    return;
                  }

                  // Replace with your method to get dist_code
                  // String distCode = getDistCode(); // Replace with your method to get dist_code
                  bool distCodeAvailable = await ApiService().checkDistCodeAvailability(dist_Code);

                  if (!distCodeAvailable) {
                    Utils.showToast('Distributor code not available. Please sync data with a valid code.');
                    return;
                  }

                  bool confirmDelete = await showSendConfirmationDialog(context);

                  if (confirmDelete) {
                    await Utils.showLoaderDialog(context ,"Sending data to server", "Please wait..." );


                    try {
                      final jsonOrders = await DatabaseHelper.instance.getSelectedOrdersAsJson(selectedOrderIds);

                      var response = await ApiService().postAllOrders(jsonOrders);

                      if (!response) {
                        Navigator.pop(context);
                        Utils.showToast("Data sending failed");
                        return;
                      }
                      Navigator.pop(context);
                      Utils.showToast("Data sent successfully");
                      deleteSelectedData();
                    } catch (error) {
                      Navigator.pop(context);
                      debugPrint("Error posting order: $error");
                      Utils.showToast("Data sending failed $error");
                    }
                  }
                },

                icon: const Icon(Icons.send_sharp),
              ),
            ),
            PopupMenuButton<int>(
              onSelected: (int value) async {
                if (value == 0) {
                  await Utils.showLoaderDialog(context ,"Checking Orders", "Please wait..." );
                  var ordersCount = await DatabaseHelper.instance.getAllOrdersCount();
                  Navigator.of(context).pop();
                  if (ordersCount < 1) {

                    await getData();
                  }
                  else {
                    Utils.showToast("Please delete or send all orders");
                  }
                } else if (value == 1) {
                  bool confirmDelete =
                  await showDeleteConfirmationDialog(context);
                  if (confirmDelete) {
                    // Perform delete action
                    deleteAll();
                  }
                } else if (value == 2) {
                  var connectivityResult = await Connectivity().checkConnectivity();
                  if (connectivityResult == ConnectivityResult.none) {
                    Utils.showToast('No internet connection');
                    return;
                  }

                  if (myDataList.isEmpty) {
                    Utils.showToast('No data to send');
                    return;
                  }// Replace with your method to get dist_code
                  bool distCodeAvailable = await ApiService().checkDistCodeAvailability(dist_Code);

                  if (!distCodeAvailable) {
                    Utils.showToast('Distributor code not available. Please sync data with a valid code.');
                    return;
                  }

                  bool confirmDelete = await showSendConfirmationDialog(context);

                  if (confirmDelete) {
                    await Utils.showLoaderDialog(context ,"Sending data to server", "Please wait..." );

                    try {
                      final jsonOrders = await DatabaseHelper.instance.getAllOrdersAsJson();

                      var response = await ApiService().postAllOrders(jsonOrders);

                      if (!response) {
                        Navigator.pop(context);
                        Utils.showToast("Data sending failed");
                        return;
                      }
                      Navigator.pop(context);
                      Utils.showToast("Data sent successfully");
                      deleteAll();
                    } catch (error) {
                      Navigator.pop(context);
                      debugPrint("Error posting order: $error");
                      Utils.showToast("Data sending failed $error");
                    }
                  }


                }else if(value == 3){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetails(),));
                }
                // else if(value == 4){
                //   Navigator.push(context, MaterialPageRoute(builder: (context) => OrderMap(),));
                // }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 0,
                  child: ListTile(
                    leading: Icon(Icons.sync),
                    title: Text('Sync'),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Icons.delete_sharp, color: Colors.redAccent),
                    title: Text('Delete All'),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: ListTile(
                    leading: Icon(Icons.send_sharp),
                    title: Text('Send All'),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 3,
                  child: ListTile(
                    leading: Icon(Icons.route),
                    title: Text('My Activities'),
                  ),
                ),
              ],
            ),
          ],
          leading: IconButton(
              onPressed: () async {
                bool confirmDelete = await showLogoutDialog(context);
                if (confirmDelete) {
                  await Utils.showLoaderDialog(context ,"Checking Orders", "Please wait..." );
                  var ordersCount = await DatabaseHelper.instance.getAllOrdersCount();
                  Navigator.of(context).pop();
                  if (ordersCount < 1) {
                    SharedPreferences s = await SharedPreferences.getInstance();
                    s.clear();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                            (route) => false);
                  }
                  else {
                    Utils.showToast("Please delete or send all orders");
                  }
                } else {
                  // Cancel delete action
                }
              },
              icon: const Icon(
                Icons.logout,
              )),
        ),
        body: Stack(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: [
                myDataList.isNotEmpty
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
                          controller: controller,
                          decoration: const InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none),
                          onChanged: onSearchTextChanged,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            controller.clear();
                            onSearchTextChanged('');
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                    ),
                    myDataList.isNotEmpty
                    ? Card(
                      color: Colors.greenAccent,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: 10),
                        child: Text(
                          'Order Amount: ${totalSum.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black, // Customize the color if needed
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    :Container(),
                    _searchResult.isNotEmpty || controller.text.isNotEmpty
                        ? ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (contextb, index) {
                          double total = Product.getTotal(myDataList[index].products);
                          MyData currentData = _searchResult[index];
                          bool isSelected = selectedOrderIds
                              .contains(currentData.invoiceId);
                          return Slidable(
                            enabled: true,
                            endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SizedBox(
                                    width: 5,
                                  ),
                                  SlidableAction(
                                    autoClose: true,
                                    onPressed: (ctx) async {
                                      AlertDialog alert = AlertDialog(
                                        title: const Text(
                                            'Are you sure?'),
                                        content: const Text(
                                            'By clicking this button, this invoice will be deleted'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Yes'),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop();
                                              deleteMyData(
                                                  _searchResult[index]);
                                            },
                                          ),
                                          TextButton(
                                            child:
                                            const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop();
                                            },
                                          ),
                                        ],
                                      );
                                      showDialog(
                                        context: context,
                                        builder:
                                            (BuildContext context) {
                                          return alert;
                                        },
                                      );
                                    },
                                    backgroundColor:
                                    Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  SlidableAction(
                                    onPressed: (ctx) async {
                                      AlertDialog alert = AlertDialog(
                                        title: const Text(
                                            'Are you sure?'),
                                        content: const Text(
                                            'By clicking this button, this invoice will be redirect to editing'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Yes'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReSelectProductsScreen(
                                                          myData: _searchResult[
                                                          index]),
                                                ),
                                              );
                                            },
                                          ),
                                          TextButton(
                                            child:
                                            const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop();
                                            },
                                          ),
                                        ],
                                      );
                                      showDialog(
                                        context: context,
                                        builder:
                                            (BuildContext context) {
                                          return alert;
                                        },
                                      );
                                    },
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ]),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: MediaQuery.devicePixelRatioOf(context), horizontal: MediaQuery.devicePixelRatioOf(context)),
                                child: Row(
                                  children: [
                                    // Checkbox(
                                    //   value: isSelected,
                                    //   onChanged: (value) {
                                    //     setState(() {
                                    //       if (value != null && value) {
                                    //         selectedOrderIds.add(currentData.invoiceId);
                                    //       } else {
                                    //         selectedOrderIds.remove(currentData.invoiceId);
                                    //       }
                                    //     });
                                    //   },
                                    // ),
                                    Checkbox(
                                      value:
                                      selectedOrderIds.contains(
                                          currentData.invoiceId),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value!) {
                                            selectedOrderIds.add(
                                                currentData
                                                    .invoiceId);
                                          } else {
                                            selectedOrderIds.remove(
                                                currentData
                                                    .invoiceId);
                                          }
                                          // If all individual checkboxes are selected, update the selectAll status
                                          selectAll = selectedOrderIds
                                              .length ==
                                              _searchResult.length;
                                        });
                                      },
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .center,
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .start,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(
                                                      context)
                                                      .size
                                                      .width *
                                                      0.7,
                                                  child: Text(
                                                    _searchResult[
                                                    index]
                                                        .customer
                                                        .name,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold
                                                    ),),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Inv# ${_searchResult[index].invoiceNumber}   (${_searchResult[index].products.length})    ",
                                                    ),
                                                    Text("Total Amount: ${total.toStringAsFixed(2) ?? 0}")
                                                  ],
                                                ),
                                                Text('Remarks : ${_searchResult[index].remarks}'),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: _searchResult == null
                            ? 0
                            : _searchResult.isEmpty
                            ? 0
                            : _searchResult.length)
                        : ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (contextb, index) {
                          double total = Product.getTotal(myDataList[index].products);
                          MyData currentData = myDataList[index];
                          bool isSelected = selectedOrderIds
                              .contains(currentData.invoiceId);
                          return Slidable(
                            enabled: true,
                            endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SizedBox(
                                    width: 5,
                                  ),
                                  SlidableAction(
                                    autoClose: true,
                                    onPressed: (ctx) async {
                                      AlertDialog alert = AlertDialog(
                                        title: const Text(
                                            'Are you sure?'),
                                        content: const Text(
                                            'By clicking this button, this invoice will be deleted'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Yes'),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop();
                                              deleteMyData(
                                                  myDataList[index]);
                                            },
                                          ),
                                          TextButton(
                                            child:
                                            const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop();
                                            },
                                          ),
                                        ],
                                      );
                                      showDialog(
                                        context: context,
                                        builder:
                                            (BuildContext context) {
                                          return alert;
                                        },
                                      );
                                    },
                                    backgroundColor:
                                    Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  SlidableAction(
                                    onPressed: (ctx) async {
                                      AlertDialog alert = AlertDialog(
                                        title: const Text(
                                            'Are you sure?'),
                                        content: const Text(
                                            'By clicking this button, this invoice will be redirect to editing'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Yes'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReSelectProductsScreen(
                                                          myData: myDataList[
                                                          index]),
                                                ),
                                              );
                                            },
                                          ),
                                          TextButton(
                                            child:
                                            const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop();
                                            },
                                          ),
                                        ],
                                      );
                                      showDialog(
                                        context: context,
                                        builder:
                                            (BuildContext context) {
                                          return alert;
                                        },
                                      );
                                    },
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ]),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: MediaQuery.devicePixelRatioOf(context), horizontal: MediaQuery.devicePixelRatioOf(context)),
                                child: Row(
                                  children: [
                                    // Checkbox(
                                    //   value: isSelected,
                                    //   onChanged: (value) {
                                    //     setState(() {
                                    //       if (value != null && value) {
                                    //         selectedOrderIds.add(currentData.invoiceId);
                                    //       } else {
                                    //         selectedOrderIds.remove(currentData.invoiceId);
                                    //       }
                                    //     });
                                    //   },
                                    // ),
                                    Checkbox(
                                      value:
                                      selectedOrderIds.contains(
                                          currentData.invoiceId),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value!) {
                                            selectedOrderIds.add(
                                                currentData
                                                    .invoiceId);
                                          } else {
                                            selectedOrderIds.remove(
                                                currentData
                                                    .invoiceId);
                                          }
                                          // If all individual checkboxes are selected, update the selectAll status
                                          selectAll = selectedOrderIds
                                              .length ==
                                              myDataList.length;
                                        });
                                      },
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .center,
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .start,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(
                                                      context)
                                                      .size
                                                      .width *
                                                      0.7,
                                                  child: Text(
                                                      myDataList[
                                                      index]
                                                          .customer
                                                          .name,
                                                      softWrap: true,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold
                                                  ),),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Inv# ${myDataList[index].invoiceNumber}   (${myDataList[index].products.length})    ",
                                                    ),
                                                    Text("Total Amount: ${total.toStringAsFixed(2) ?? 0}")
                                                  ],
                                                ),
                                                Text('Remarks : ${myDataList[index].remarks}'),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: myDataList == null
                            ? 0
                            : myDataList.isEmpty
                            ? 0
                            : myDataList.length),
                    const SizedBox(
                      height: 48,
                    )
                  ],
                )
                    : Center(
                  child: Column(
                    children: [
                      Lottie.asset(kIsWeb
                          ? 'not_found.json'
                          : 'assets/not_found.json'),
                      const Text(
                        "No invoice created yet",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectSectorAndAreaScreen(),
                ));
          },
          label: const Text("Add New"),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> deleteSelectedData() async {
    final dbPath = path.join(await getDatabasesPath(), 'eOrderBook.db');
    Database database = await openDatabase(dbPath);

    for (int orderId in selectedOrderIds) {
      await database.delete(
        'eorderbook_master',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      await database.delete(
        'eorderbook',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
    }

    setState(() {
      myDataList.removeWhere(
              (element) => selectedOrderIds.contains(element.invoiceId));
      _searchResult.removeWhere(
              (element) => selectedOrderIds.contains(element.invoiceId));
      selectedOrderIds.clear();
    });

    database.close();
  }

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

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
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

  Future<bool> showSendConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Send data confirmation"),
          content: const Text("Are you sure to send all data to backend?"),
          actions: <Widget>[
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("SEND"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>>? info;

  List<Area> ares = [];
  List<Sector> sectors = [];
  List<Account> customer = [];

  List<MyData> myDataList = [];

  Future<void> deleteMyData(MyData myData) async {
    final dbPath = path.join(await getDatabasesPath(), 'eOrderBook.db');
    Database database = await openDatabase(dbPath);
    String tableName =
        'eorderbook_master'; // Replace with the actual table name

    await database.delete(
      tableName,
      where: 'order_id = ?',
      whereArgs: [myData.invoiceId],
    );
    setState(() {
      myDataList
          .removeWhere((element) => element.invoiceId == myData.invoiceId);
    });

    // Close the database
    await database.close();
  }

  Future<void> deleteAll() async {
    final dbPath = path.join(await getDatabasesPath(), 'eOrderBook.db');
    Database database = await openDatabase(dbPath);
    await database.delete('eorderbook');
    await database.delete('eorderbook_master');
    setState(() {
      myDataList.clear();
      selectedOrderIds.clear();
    });
    database.close();
  }

  Future<void> deleteMyDataSearch(MyData myData) async {
    final dbPath = path.join(await getDatabasesPath(), 'eOrderBook.db');
    Database database = await openDatabase(dbPath);

    await database.delete(
      'eorderbook_master',
      where: 'order_id = ?',
      whereArgs: [myData.invoiceId],
    );

    await database.delete(
      'eorderbook',
      where: 'order_id = ?',
      whereArgs: [myData.invoiceId],
    );

    setState(() {
      myDataList
          .removeWhere((element) => element.invoiceId == myData.invoiceId);
      _searchResult
          .removeWhere((element) => element.invoiceId == myData.invoiceId);
    });
    database.close();
  }

  TextEditingController controller = TextEditingController();

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var element in myDataList) {
      if (element.customer.name
          .trim()
          .toLowerCase()
          .contains(text.trim().toLowerCase())) {
        // await element.setSectorArea();
        _searchResult.add(element);
      }
    }

    setState(() {});
  }

  List<MyData> _searchResult = [];
}