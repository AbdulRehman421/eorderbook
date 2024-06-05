import 'package:eorderbook/models/account.dart';
import 'package:eorderbook/models/area.dart';
import 'package:eorderbook/models/sector.dart';
import 'package:eorderbook/screens/ProductAutoComplete.dart';
import 'package:eorderbook/screens/invoice_list_screen.dart';
import 'package:eorderbook/screens/select_products_screen.dart';
import 'package:eorderbook/widgets/ConstantWidget.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SelectCustomerScreen extends StatefulWidget {
  const SelectCustomerScreen(
      {Key? key, required this.areaId, required this.sectorId})
      : super(key: key);

  final Area areaId;
  final Sector sectorId;

  @override
  _SelectCustomerScreenState createState() => _SelectCustomerScreenState();
}

class _SelectCustomerScreenState extends State<SelectCustomerScreen> {
  final ScrollController _scrollController = ScrollController();

  final int pageSize = 30; // number of items to display per page
  int currentPage = 1; // current page number, starting from 1
  List<Account> items = [];

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() async {
    final int offset = currentPage * pageSize;
    final List<Account> newItems = await fetchItems(offset, pageSize);
    setState(() {
      controller.text.isNotEmpty
          ? _searchResult.addAll(newItems)
          : items.addAll(newItems);
      currentPage++;
      isLoaded = false;
    });
  }

  bool isLoaded = false;

  var total = 2122;

  Future<List<Account>> fetchItems(int offset, int limit) async {
    List<Account> fetched = [];
    setState(() {
      isLoaded = true;
    });
    final path = join(await getDatabasesPath(), 'eOrderBook.db');
    Database database = await openDatabase(path);
    int? count = controller.text.isNotEmpty
        ? Sqflite.firstIntValue(await database.rawQuery(
            "SELECT COUNT(*) FROM account WHERE areacd=${widget.areaId.areaCd} and name LIKE '%${controller.text}%'"))
        : Sqflite.firstIntValue(await database.rawQuery(
            "SELECT COUNT(*) FROM account where areacd=${widget.areaId.areaCd}"));
    List<Map<String, dynamic>> parties = controller.text.isNotEmpty
        ? await database.rawQuery(
            "SELECT * FROM account WHERE areacd=${widget.areaId.areaCd} and name LIKE '%${controller.text}%' ORDER BY name LIMIT $limit OFFSET $offset")
        : await database.rawQuery(
            "SELECT * FROM account where areacd=${widget.areaId.areaCd} ORDER BY name LIMIT $limit OFFSET $offset");
    database.close();

    for (var customer in parties) {
      debugPrint(customer["name"]);
      final code = customer['code']; // Extract the code
      final hasZeroOrder = await _hasZeroOrderAmountInLocalDB(code);
      final hasNonZeroOrder = await _hasNonZeroOrderAmountInLocalDB(code);
      fetched.add(Account(
        id: customer['ID'],
        name: customer['name'],
        address: "${customer['address']}",
        code: customer['code'],
        distCode: customer['dist_code'],
        areaCd: customer['areacd'],
        active: customer['active'],
        lic_exp_date: customer['lic_exp_date'],
        cardColor: hasZeroOrder && hasNonZeroOrder
            ? Colors.grey
            : (hasZeroOrder
                ? Colors.red
                : (hasNonZeroOrder ? Colors.green : null)),
      ));
    }
    if (parties.length <= count!) {
      isLoaded = false;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    return fetched;
  }

  initial() async {
    controller.text.isNotEmpty
        ? _searchResult.addAll(await fetchItems(0, 30))
        : items.addAll(await fetchItems(0, 30));
    debugPrint(items.length.toString());
    setState(() {});
  }

  Future<bool> _invoiceData(Account customer) async {
    final path = join(await getDatabasesPath(), 'eOrderBook.db');
    Database database = await openDatabase(path);
    String query =
        'SELECT COUNT(*) FROM eorderbook_master WHERE code = ${customer.code}';

    List<Map<String, dynamic>> result = await database.rawQuery(query);
    int count = Sqflite.firstIntValue(result) ?? 0;

    database.close();

    if (count > 0) {
      return true;
    } else {
      return false;
    }
  }

  String checkLicExpDate = '';

  Future<void> getCheckLicExpDateFromSharedPreferences() async {
    // Retrieve check_lic_expdate value from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Update the state variable with the retrieved value
      checkLicExpDate = prefs.getString('check_lic_expdate') ?? '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initial();
    _scrollController.addListener(_onScroll);
    getCheckLicExpDateFromSharedPreferences();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _hasZeroOrderAmountInLocalDB(int code) async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(join(databasePath, 'eOrderBook.db'));

    // Check if there is at least one order with orderAmount = 0
    final hasZeroOrder = await database.query(
      'eorderbook_master',
      where: 'code = ? AND order_amount = 0',
      whereArgs: [code],
    );

    database.close();

    return hasZeroOrder.isNotEmpty;
  }

  Future<bool> _hasNonZeroOrderAmountInLocalDB(int code) async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(join(databasePath, 'eOrderBook.db'));

    // Check if there is at least one order with orderAmount > 0
    final hasNonZeroOrder = await database.query(
      'eorderbook_master',
      where: 'code = ? AND order_amount > 0',
      whereArgs: [code],
    );

    database.close();

    return hasNonZeroOrder.isNotEmpty;
  }

  Future<bool> _isCodePresentInLocalDB(String code) async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(join(databasePath, 'eOrderBook.db'));
    final result = await database
        .query('eorderbook_master', // Replace with the correct table name
            where: 'code = ?',
            whereArgs: [code]);
    database.close();
    return result.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InvoiceListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.home))
        ],
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "Select Customer",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              widget.areaId.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Container(
                padding: const EdgeInsets.only(bottom: 100),
                child: items.isNotEmpty
                    ? Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue)),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.only(left: 6, right: 0),
                              leading: const Icon(Icons.search),
                              title: TextField(
                                autofocus: false,
                                controller: controller,
                                decoration: const InputDecoration(
                                    hintText: 'Search',
                                    border: InputBorder.none),
                                textInputAction: TextInputAction.search,
                                onChanged: onSearchTextChanged,
                              ),
                              trailing: SizedBox(
                                width: 80,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                      child: const Icon(
                                        Icons.cancel,
                                        size: 28,
                                      ),
                                      onTap: () {
                                        controller.clear();
                                        onSearchTextChanged('');
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                    ),
                                    InkWell(
                                      child: const Icon(
                                        Icons.search,
                                        size: 28,
                                      ),
                                      onTap: () {
                                        currentPage = 1;
                                        _searchResult.clear();
                                        setState(() {});
                                        initial();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _searchResult.isNotEmpty || controller.text.isNotEmpty
                              ? ListView.separated(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(
                                      parent: ClampingScrollPhysics()),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () async {
                                        if (checkLicExpDate == 'N') {
                                          // Navigate to next screen directly if checkLicExpDate is 'Y'
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductAutoComplete(
                                                  customer: items[index],
                                                  area: widget.areaId,
                                                  sector: widget.sectorId,
                                                ),
                                              ));
                                        } else {
                                          DateTime licenseExpirationDate;
                                          try {
                                            // Parsing the license expiration date
                                            licenseExpirationDate =
                                                DateTime.parse(
                                                    _searchResult[index]
                                                        .lic_exp_date
                                                        .toString());
                                          } catch (e) {
                                            print(
                                                'Error parsing license expiration date: $e');
                                            return; // Return if parsing fails
                                          }

                                          if (licenseExpirationDate
                                              .isBefore(DateTime.now())) {
                                            // Show license expired prompt
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      Text('License Expired'),
                                                  content: Text(
                                                      'Your license for ${_searchResult[index].name} has expired.'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            // Show confirmation dialog
                                            bool available = await _invoiceData(
                                                _searchResult[index]);
                                            if (available) {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                    buildContext) {
                                                  return AlertDialog(
                                                    title:
                                                        Text('Are you sure?'),
                                                    content: Text(
                                                        'It will create another order for this customer'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: Text('Yes'),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ProductAutoComplete(
                                                                  customer:
                                                                      items[
                                                                          index],
                                                                  area: widget
                                                                      .areaId,
                                                                  sector: widget
                                                                      .sectorId,
                                                                ),
                                                              ));
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text('Cancel'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductAutoComplete(
                                                      customer: items[index],
                                                      area: widget.areaId,
                                                      sector: widget.sectorId,
                                                    ),
                                                  ));
                                            }
                                          }
                                        }
                                      },
                                      child: Card(
                                        color: _searchResult[index].cardColor,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
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
                                                    Text(
                                                      _searchResult[index].name,
                                                      style:  TextStyle(
                                                          color: _searchResult[index].cardColor != null ? Colors.white : Colors.black,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(_searchResult[index]
                                                        .address , style: TextStyle(
                                                      color: _searchResult[index].cardColor != null ? Colors.white : Colors.black,),),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: _searchResult.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider(height: 0);
                                  },
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(
                                      parent: ClampingScrollPhysics()),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () async {
                                        if (checkLicExpDate == 'N') {
                                          // Navigate to next screen directly if checkLicExpDate is 'Y'
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductAutoComplete(
                                                  customer: items[index],
                                                  area: widget.areaId,
                                                  sector: widget.sectorId,
                                                ),
                                              ));
                                        } else {
                                          DateTime licenseExpirationDate;
                                          try {
                                            // Parsing the license expiration date
                                            licenseExpirationDate =
                                                DateTime.parse(items[index]
                                                    .lic_exp_date
                                                    .toString());
                                          } catch (e) {
                                            print(
                                                'Error parsing license expiration date: $e');
                                            return; // Return if parsing fails
                                          }

                                          if (licenseExpirationDate
                                              .isBefore(DateTime.now())) {
                                            // Show license expired prompt
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      Text('License Expired'),
                                                  content: Text(
                                                      'Your license for ${items[index].name} has expired.'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            // Show confirmation dialog
                                            bool available = await _invoiceData(
                                                items[index]);
                                            if (available) {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                    buildContext) {
                                                  return AlertDialog(
                                                    title:
                                                        Text('Are you sure?'),
                                                    content: Text(
                                                        'It will create another order for this customer'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: Text('Yes'),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ProductAutoComplete(
                                                                  customer:
                                                                      items[
                                                                          index],
                                                                  area: widget
                                                                      .areaId,
                                                                  sector: widget
                                                                      .sectorId,
                                                                ),
                                                              ));
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text('Cancel'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductAutoComplete(
                                                      customer: items[index],
                                                      area: widget.areaId,
                                                      sector: widget.sectorId,
                                                    ),
                                                  ));
                                            }
                                          }
                                        }
                                      },
                                      child: Card(
                                        color: items[index].cardColor,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          // Changed EdgeInsets.only(left: 16) to EdgeInsets.all(16)
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
                                                    Text(
                                                      items[index].name,
                                                      style:  TextStyle(
                                                        color: items[index].cardColor != null ? Colors.white : Colors.black,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(items[index]
                                                            .address , style: TextStyle(
                                                          color: items[index].cardColor != null ? Colors.white : Colors.black,
                                                        ),),
                                                        Text('Lic Exp : ${items[index].lic_exp_date}  ' ,style: TextStyle(

                                                          color: items[index].cardColor != null ? Colors.white  : DateTime.parse(items[index]
                                                              .lic_exp_date
                                                              .toString())
                                                              .isBefore(DateTime.now())
                                                              ? Colors.red
                                                              : Colors.black, fontWeight: FontWeight.bold),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: items.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider(height: 0);
                                  },
                                ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (isLoaded)
                            const SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(),
                            ),
                          const SizedBox(
                            height: 48,
                          )
                        ],
                      )
                    : ConstantWidget.NotFoundWidget(
                        context,
                        "No Customer found",
                      ),
              ),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  String? editableId;
  bool editing = false;
  int page = 0;

  TextEditingController controller = TextEditingController();

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    currentPage = 1;

    for (var element in items) {
      if (element.name
          .trim()
          .toLowerCase()
          .contains(text.trim().toLowerCase())) {
        _searchResult.add(element);
      }
    }

    setState(() {});
  }

  List<Account> _searchResult = [];
}
